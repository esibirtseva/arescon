package net.avkorneenkov;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.function.Consumer;

public class IOUtil {

    // read file as UTF-8 String
    public static String readFile( final Path path ) throws IOException {
        return new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
    }
    public static String readFile( final String path, final String basePath ) throws IOException {
        return readFile(Paths.get(basePath + path));
    }
    public static String readFile( final String path ) throws IOException {
        return readFile(Paths.get(path));
    }

    public static HashMap<String, String> loadFiles( final String resourcePath ) throws IOException {
        final HashMap<String, String> files = new HashMap<>();

        Files.walk(Paths.get(resourcePath), 1).forEach(new Consumer<Path>() {
            @Override
            public void accept(Path path) {
                if (Files.isRegularFile(path)) {
                    String filename = path.getFileName().toString();
                    try {
                        files.put(filename.substring(0, filename.indexOf('.')), IOUtil.readFile(path));
                    } catch ( IOException e ) { throw new RuntimeException(e); }
                }
            }
        });

        return files;
    }

}
