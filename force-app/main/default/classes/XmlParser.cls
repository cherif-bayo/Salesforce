public class XmlParser{

    private static String BEGIN_NODE = '<';
    private static String END_NODE = '>';
    private static String BEGIN_END_NODE = '</';

    public static String CreateNode(String nameNode){
        return BEGIN_NODE + nameNode + END_NODE + BEGIN_END_NODE  + nameNode + END_NODE;
    }
    
    public static String InsertInNode(String node, String insertion){
        Integer indexEndNodeOpened = node.indexOf(END_NODE);
        
        return node.substring(0, indexEndNodeOpened + 1) + insertion + node.substring(indexEndNodeOpened + 1, node.length());
    }

}