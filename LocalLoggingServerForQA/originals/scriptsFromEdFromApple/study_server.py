#!/usr/bin/env python

import argparse
import studyResults
import re
import json
from sys import exc_info
from traceback import format_tb


class TestApp:
    """WSGI web application to support testing ResearchKit's uploaded content
    """

    HeaderLookup = { 'HTTP_X_RESEARCHKIT_UPLOADUUID' : 'uploadUUID',
                     'HTTP_X_RESEARCHKIT_STUDYIDENTIFIER' : 'studyIdentifier',
                     'HTTP_X_RESEARCHKIT_SUBJECTUUID' : 'subjectUUID' }

    def upload(self, environ, start_response):
        """Handler for an upload. Retrieves the body content
        and decrypts, decompresses, and thus verifies the content.
        Prints some debugging content to the console so the upload
        content can be verified during development.
        """
        body= ''
        try:
            length= int(environ.get('CONTENT_LENGTH', '0'))
        except ValueError:
            length= 0

        if length > 0:
            body= environ['wsgi.input'].read(length)

        # Look for the ResearchKit HTTP headers
        # If not present, print a warning
        try:
            headers = {}
            for header in self.HeaderLookup.keys():
                headers[self.HeaderLookup[header]] = environ[header]
            print "HTTP header info: %s" %  json.dumps(headers, sort_keys = True,
                                                       indent=4, separators=(',', ': '))
        except:
            print "[WARN] ResearchKit HTTP headers missing"
            pass
        
        # Try decrypting, in case there is a CMS wrapper.
        # Could alternatively decide whether to try to decrypt
        # based on the content type header.
        try:
            decrypted = self.decryptor.decrypt(body)
        except:
            print "[WARN] content not in CMS envelope"
            decrypted = body
            pass

        # Try to unpack the resulting file, which could be gzipped,
        # containing multipart MIME, or could be a zip.
        unpacked = studyResults.StudyCMS(decrypted, None)

        print "metadata: %s" % json.dumps(unpacked.header, sort_keys=True,
                                          indent=4, separators=(',', ': '))

        # Print some information about the first content file, if it is
        # likely to be printable content (e.g. JSON)
        if len(unpacked.getFiles()) > 0:
            contentType = unpacked.getFiles()[0].contentType
            content = unpacked.getFiles()[0].content
            if contentType == "application/json" or contentType == "text/json":
                print "data: %s" % json.dumps(json.loads(content), sort_keys=True,
                                              indent=4, separators=(',', ': '))
            elif contentType == "text/plain":
                print "data: %s" % content

        start_response('200 OK', [('Content-Type','text/json')])
        return ""

    def not_found(self, environ, start_response):
        """Generic not found URL handler"""
        start_response('404 NOT FOUND', [('Content-Type', 'text/plain')])
        return ['Not Found']


    def __init__(self, keypath, certpath, sslpath):
        self.decryptor = studyResults.CMSDecryptor(keypath, certpath, sslpath)

    def __call__(self, environ, start_response):
        """Maps paths to handlers"""
        urls = [
            (r'^api/upload$', self.upload)
        ]
        path = environ.get('PATH_INFO','').lstrip('/')
        for regex, callback in urls:
            match = re.search(regex, path)
            if match is not None:
                return callback(environ, start_response)

        return self.not_found(environ, start_response)


class ExceptionMiddleware(object):
    """Middleware to print exceptions."""

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        appiter = None
        try:
            appiter = self.app(environ, start_response)
            for item in appiter:
                yield item
        except:
            e_type, e_value, tb = exc_info()
            traceback = ['Traceback (most recent call last):']
            traceback += format_tb(tb)
            traceback.append('%s: %s' % (e_type.__name__, e_value))
            try:
                start_response('500 INTERNAL SERVER ERROR', [
                               ('Content-Type', 'text/plain')])
            except:
                pass
            yield '\n'.join(traceback)

        if hasattr(appiter, 'close'):
            appiter.close()



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--key",help="researcher private key PEM file")
    parser.add_argument("-i", "--identity",help="researcher certificate as PEM file")
    parser.add_argument("--openssl", help="path to OpenSSL binary to use", default="openssl")
    args = parser.parse_args()
    app = ExceptionMiddleware(TestApp(args.key, args.identity, args.openssl))

    from wsgiref.simple_server import make_server
    srv = make_server('', 8080, app)
    srv.serve_forever()



if __name__ == '__main__':
    main()
