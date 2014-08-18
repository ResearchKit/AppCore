#!/usr/bin/env python

import argparse
import subprocess
from subprocess import PIPE, STDOUT
import tempfile
import os
import os.path
import shutil
import bz2
import struct
import json
import dateutil.parser
import time
import zipfile
import errno
import email
import StringIO

DEVNULL = open(os.devnull, 'wb')

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

class StudyFile:
    """File output by CMS"""
    def __init__(self, filename, contentType, timestamp):
        self.filename = filename
        self.contentType = contentType
        self.timestamp = timestamp

    def setContent(self, data):
        self.content = data


class StudyCMS:
    """Study CMS unpacker"""

    def initWithBz2Packed(self, decryptedData):
        unpackedData = bz2.decompress(decryptedData)
        offset = 0
        self.version = struct.unpack_from('!L',unpackedData,offset)[0]
        offset = offset + 4
        headerLen = struct.unpack_from('!L',unpackedData,offset)[0]
        offset = offset + 4
        headerData = unpackedData[offset:headerLen+offset]
        self.header = json.loads(headerData)

        files = []
        if (self.header.has_key('files')):
            for entry in self.header['files']:
                files.append(StudyFile(entry['filename'], entry['contentType'], entry['timestamp']))
        else:
            files = [ StudyFile('data', self.header['contentType'], self.header['timestamp']) ]

        for entry in files:
            offset = offset + headerLen
            dataLen = struct.unpack_from('!L',unpackedData,offset)[0]
            offset = offset + 4
            entry.setContent(unpackedData[offset:dataLen+offset])

        self.files = files

    def initWithBz2Mime(self, decryptedData):
        unpackedData = bz2.decompress(decryptedData)
        message = email.message_from_string(unpackedData)
        if (not message.is_multipart()):
            raise
        files = []
        for part in message.walk():
            fn = part.get_filename()
            if fn == None:
                continue
            if fn == "info.json":
                self.header = json.loads(part.get_payload())
            elif len(fn) > 0:
                newfile = StudyFile(fn, part.get_content_type(), "")
                newfile.setContent(part.get_payload())
                files.append(newfile)
        self.files = files

    def initWithZip(self, decryptedData):
        zipContent = StringIO.StringIO(decryptedData)
        with zipfile.ZipFile(zipContent, 'r') as zip:
            self.header = json.loads(zip.read("info.json"))
            files = []
            for entry in self.header['files']:
                studyFile = StudyFile(entry['filename'], entry['contentType'], entry['timestamp'])
                studyFile.setContent(zip.read(entry['filename']))
                files.append(studyFile)
            self.files = files
        zipContent.close()

    def __init__(self, decryptedData, name):
        self.name = name
        try:
            self.initWithBz2Packed(decryptedData)
            return
        except:
            try:
                self.initWithBz2Mime(decryptedData)
                return
            except:
                self.initWithZip(decryptedData)


    def header(self):
        return self.header

    def content(self):
        """Content of the first file"""
        return self.files[0].content

    def studyId(self):
        return self.header['study']

    def timestamp(self):
        return dateutil.parser.parse(self.header['timestamp'])

    def getFiles(self):
        """Returns array of StudyFile"""
        return self.files

    def write(self, outdir):
        """Write the study to a file in the specified directory"""
        outpath = os.path.join(outdir, ''.join([self.dataTypeName(),'_',self.name,'.',self.extension()]))
        with open(outpath,'w') as outfile:
            outfile.write(self.content)
        t = time.mktime(self.timestamp().timetuple())
        os.utime(outpath, (t,t))
    

class CMSDecryptor:
    """CMS decryptor"""
    def __init__(self, keypath, certpath, sslpath):
        self.keypath = keypath
        self.certpath = certpath
        self.sslpath = sslpath
        self.tmpdir = tempfile.mkdtemp()

    def decrypt(self, data):
        """Decrypt the CMS data using the cert and private key specified"""
        (fh, datapath) = tempfile.mkstemp(dir=self.tmpdir)
        datafile = os.fdopen(fh, "w")
        datafile.write(data)
        datafile.close()

        outpath = datapath + '.out'

        args = [self.sslpath, 'cms', '-decrypt', '-inform', 'DER', '-in', datapath, '-inkey', self.keypath, '-certfile', self.certpath, '-out', outpath]
        subprocess.check_call(args, stdout=DEVNULL, stderr=DEVNULL)
        
        outfh = open(outpath, 'r')
        outdata = outfh.read()
        outfh.close()
        
        os.unlink(outpath)
        os.unlink(datapath)

        return outdata
        
    def __del__(self):
        shutil.rmtree(self.tmpdir)


def doDecode(data, decryptor, name, outpath, verbose):
    if verbose:
        print "decrypting " + name
    decrypted = decryptor.decrypt(data)
    unpacked = StudyCMS(decrypted,name)
    unpacked.write(outpath)
    

def decrypt(keypath, certpath, zippath, outpath, sslpath, verbose):
    decryptor = CMSDecryptor(keypath, certpath, sslpath)
    
    mkdir_p(outpath)
    
    if os.path.isdir(zippath):
        namelist = [x for x in os.listdir(zippath) if x.endswith('.cms')]
        for name in namelist:
            with open(os.path.join(zippath,name),'r') as cmsfile:
                data = cmsfile.read()
                doDecode(data, decryptor, name, outpath, verbose)

    else:
        with zipfile.ZipFile(zippath,'r') as zipf:
            namelist = [x for x in zipf.namelist() if x.endswith('.cms')]
            for name in namelist:
                data = zipf.read(name)
                doDecode(data, decryptor, name, outpath, verbose)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--key",help="researcher private key PEM file")
    parser.add_argument("-i", "--identity",help="researcher certificate as PEM file")
    parser.add_argument("-o", "--out", help="directory in which to place output",default=".")
    parser.add_argument("--openssl", help="path to OpenSSL binary to use", default="openssl")
    parser.add_argument("-v", "--verbose", action="store_true", help="describe files being decrypted")
    parser.add_argument("zipOrDir", help="path to downloaded zip file, or to unzipped directory containing encrypted data")

    args = parser.parse_args()

    decrypt(args.key, args.identity, args.zipOrDir, args.out, args.openssl, args.verbose)


if __name__ == "__main__":
    main()
