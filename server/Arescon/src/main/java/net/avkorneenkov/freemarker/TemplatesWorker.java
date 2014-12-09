package net.avkorneenkov.freemarker;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import io.undertow.server.HttpServerExchange;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.util.Map;

public class TemplatesWorker {

    private final Configuration config;

    public TemplatesWorker( File templatesPath ) throws IOException {
        this.config = new Configuration(Configuration.VERSION_2_3_21);
        this.config.setDirectoryForTemplateLoading(templatesPath);
        this.config.setDefaultEncoding("UTF-8");
        this.config.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
    }

    public void getTemplated( Map<String, Map<String, String>> data, String templateFilename, Writer outputStream )
            throws IOException, TemplateException
    {
        final Template template = config.getTemplate(templateFilename);
        template.process(data, outputStream);
    }

    public static void nullWriter( Writer response, HttpServerExchange exchange ) { }

}
