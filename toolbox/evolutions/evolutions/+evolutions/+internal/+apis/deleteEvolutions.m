function [ success, evolutionsDeleted ] = deleteEvolutions( treeId, evolutionId )




R36
treeId( 1, : )char
evolutionId( 1, : )char
end 

currentTreeInfo = evolutions.internal.getDataObject( treeId );
evolutionInfo = evolutions.internal.getDataObject( evolutionId );

[ success, evolutionsDeleted ] = evolutions.internal.deleteEvolutions( currentTreeInfo, evolutionInfo );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpw9o2cc.p.
% Please follow local copyright laws when handling this file.

