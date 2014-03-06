function [c] = gmailclient(username, password)
url = 'https://www.google.com/accounts/ServiceLoginBoxAuth';
postdata =sprintf( 'continue=https://gmail.google.com/gmail&service=mail&Email=%s&Passwd=%s&submit=null', username, password)
        c = p.read()