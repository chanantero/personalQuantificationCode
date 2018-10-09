DocNode = xmlread('../Datos/ActividadesNuevo.xml');
doctype = DocNode.getDoctype;
domImpl = DocNode.getImplementation();
% doctype = domImpl.createDocumentType('global', 'SYSTEM', 'global.dtd');
% DocNode.appendChild(doctype);
xmlwrite('../Datos/ActividadesNuevo2.xml', DocNode)

entities = doctype.getEntities
notations = doctype.getNotations;
doctype.getInternalSubset

%%%%
docNode2 = com.mathworks.xml.XMLUtils.createDocument('root');
docNode2.getDoctype
domImpl2 = docNode.getImplementation();
doctype2 = domImpl.createDocumentType('root', 'SYSTEM', 'root.dtd');
docNode2.appendChild(doctype);

root = docNode.getDocumentElement;
child = docNode.createElement('child');
child.appendChild(docNode.createTextNode('Hello World!'));
root.appendChild(child);

xmlwrite('../Datos/ActividadesNuevo3.xml', docNode2)