package net.avkorneenkov.undertow;

import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.PathHandler;
import io.undertow.server.handlers.form.FormData;
import io.undertow.server.handlers.form.FormDataParser;
import io.undertow.server.handlers.form.FormParserFactory;

import java.io.IOException;
import java.util.Map;

import static io.undertow.Handlers.path;

public class UndertowUtil {

    private static final FormParserFactory FORM_PARSER_FACTORY = FormParserFactory.builder().build();

    static PathHandler appendPathHandler( PathHandler handler,
                                          Map<String, HttpHandler> paths,
                                          String indexHandlerName )
    {
        for (final String path : paths.keySet()) {
            if (path.equalsIgnoreCase(indexHandlerName)) {
                System.out.println("Index handler set: /");
                handler.addPrefixPath("/", paths.get(path));
            } else {
                System.out.println("Handler set: /" + path);
                handler.addPrefixPath("/" + path, paths.get(path));
            }
        }

        return handler;
    }

    public static PathHandler buildPathHandler( Map<String, HttpHandler> paths, String indexHandlerName ) {
        return appendPathHandler(path(), paths, indexHandlerName);
    }

    public static PathHandler buildPathHandler( Map<String, HttpHandler> paths ) {
        return appendPathHandler(path(), paths, "index");
    }

    public static FormData parsePostData( final HttpServerExchange exchange ) throws IOException {
        final FormDataParser parser = FORM_PARSER_FACTORY.createParser(exchange);
        if (parser == null) return null;
        parser.setCharacterEncoding("UTF-8");
        return parser.parseBlocking();
    }

}
