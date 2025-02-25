function dep = createBusDependency( upComp, downNode, type, downComp )




R36
upComp( 1, 1 )dependencies.internal.graph.Component;
downNode( 1, 1 )dependencies.internal.graph.Node;
type( 1, 1 )dependencies.internal.graph.Type;
downComp = Component.createRoot( downNode );
end 

import dependencies.internal.graph.Component;
import dependencies.internal.graph.Dependency;

if ~isa( downComp, "dependencies.internal.graph.Component" )
compType = dependencies.internal.graph.Type( "Variable" );
downComp = Component( downNode, downComp, compType, 0, "", "", "" );
end 

rel = dependencies.internal.graph.Type( "Bus" );

dep = Dependency( upComp, downComp, type, rel );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTSTZ7S.p.
% Please follow local copyright laws when handling this file.

