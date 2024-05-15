package fnf.utils;

class ParseUtil {
    public static function parseYaml(path:String):Dynamic return yaml.Yaml.parse(Paths.getContent(Paths.yaml(path)), yaml.Parser.options().useObjects());
}