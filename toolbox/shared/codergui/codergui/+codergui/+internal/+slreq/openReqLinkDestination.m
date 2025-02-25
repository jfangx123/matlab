function openReqLinkDestination( aRangeIdentifier, aLinkIndex )






R36
aRangeIdentifier( 1, 1 )string
aLinkIndex( 1, 1 )double
end 

[ file, id ] = codergui.internal.slreq.decomposeRangeIdentifier( aRangeIdentifier );


linkSet = codergui.internal.slreq.loadLinkSet( file );
destination = getLinkDestination( linkSet, id, aLinkIndex );
slreq.show( destination );
end 

function destination = getLinkDestination( aLinkSet, id, aLinkIndex )
textItem = aLinkSet.getTextItem( '' );
textRange = textItem.getRange( char( id ) );
if isempty( textRange )
error( message( 'coderWeb:reportMessages:requirementLinkSetOutdated' ) );
end 
links = textRange.getLinks(  );
if aLinkIndex > numel( links )
error( message( 'coderWeb:reportMessages:requirementLinkSetOutdated' ) );
end 
link = links( aLinkIndex );
destination = struct( 'domain', link.destDomain, 'artifact', link.destUri, 'id', link.destId );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHj8uSd.p.
% Please follow local copyright laws when handling this file.

