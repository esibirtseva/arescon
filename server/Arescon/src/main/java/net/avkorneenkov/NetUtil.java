package net.avkorneenkov;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import java.io.FileInputStream;
import java.io.UnsupportedEncodingException;
import java.security.KeyStore;
import java.util.List;
import java.util.Properties;

public class NetUtil {

    private static HttpClient client;

    @FunctionalInterface
    public static interface StringHandler { void handle( String str ); }

    public static void post( String url, List<NameValuePair> params, StringHandler handler ) {
        if (client == null) client = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost(url);
        // set params
        if (params != null) {
            try {
                httpPost.setEntity(new UrlEncodedFormEntity(params, "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
        // execute
        try {
            HttpResponse response = client.execute(httpPost);
            HttpEntity respEntity = response.getEntity();
            if (respEntity != null) {
                // handle
                handler.handle(EntityUtils.toString(respEntity));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void mail( String to, String from, String subject, String message ) {
        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", "localhost");
        Session session = Session.getDefaultInstance(properties);
        try {
            MimeMessage mimeMessage = new MimeMessage(session);
            mimeMessage.setFrom(new InternetAddress(from));
            mimeMessage.addRecipient(Message.RecipientType.TO,
                    new InternetAddress(to));
            mimeMessage.setSubject(subject);
            mimeMessage.setText(message);
            Transport.send(mimeMessage);
        } catch ( MessagingException e ) {
            e.printStackTrace();
        }
    }

    public static SSLContext createSSLContext( final String keyStorePath, final char[] keyStorePassword )
            throws Exception {

        final SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
        final KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance("SunX509");
        final KeyStore keyStore = KeyStore.getInstance("JKS");

        keyStore.load(new FileInputStream(keyStorePath), keyStorePassword);
        keyManagerFactory.init(keyStore, keyStorePassword);
        sslContext.init(keyManagerFactory.getKeyManagers(), null, null);

        return sslContext;
    }

}
