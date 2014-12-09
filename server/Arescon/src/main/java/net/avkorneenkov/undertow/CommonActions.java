package net.avkorneenkov.undertow;

import freemarker.template.TemplateException;
import net.avkorneenkov.freemarker.TemplatesWorker;

import java.io.IOException;
import java.io.Writer;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class CommonActions {

    private TemplatesWorker templates;

    public CommonActions( TemplatesWorker templates ) {
        this.templates = templates;
    }

    public void getTemplated( ResultSet data, String[] columns, String templateFilename, Writer outputStream )
            throws SQLException, IOException, TemplateException
    {
        if (data == null || outputStream == null || columns == null || columns.length == 0) return;

        while (data.next()) {
            Map<String, String> dataMap = new HashMap<>();
            Map<String, Map<String, String>> root = new HashMap<>();
            root.put("map", dataMap);
            for (String column : columns) {
                dataMap.put(column, data.getString(column));
            }
            this.templates.getTemplated(root, templateFilename, outputStream);
        }
    }
}
