El scrip desarrollado en ruby extrae información y documentación de http://www.minhap.gob.es/es-es/servicios/contratacion/junta%20consultiva%20de%20contratacion%20administrativa/informes/Paginas/default.aspx

Para esto se utilizan 3 ficheros:
1) main.rb: fichero principal
2) util.rb: fichero con funciones generales auxiliares
3) xmlUtil.rb: ficheron con funciones de manejo de xml

El comando para generer un initial dump es: "ruby main.rb" (dependiendo de la ubicación de main.rb).

Cada vez que se el comando, sea para generar un initial dump o un update, se genera un fichero de bitácora con información para generar el siguiente update.

El comando para generar un update es: "ruby main.rb update logbook.xml" (dependiendo de la ubicación de main.rb y logbook.xml). El fichero logbook.xml corresponde al fichero de bitácora generado en el dump previo. El dump de update se generará según este fichero.

El fichero logbook.xml es generado teniendo en cuenta el documento más actual de cada categoría. Cuando el se está generando el update se evalúa si existe algún fichero más actual. Si exite se agrega, de lo contrario no.

Además de esto un fichero de log es generado para informar avances y posibles errores.