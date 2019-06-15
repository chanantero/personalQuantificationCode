function [T, nodeIndexMatrix] = XMLstructure2ExtendedTables(nodeTreeStruct, unify)
%error('Cambia esta función!!!!')
[T, nodeIndexMatrix] = XMLstructure2XMLtable(nodeTreeStruct, 'extend', true, 'unify', unify);
end