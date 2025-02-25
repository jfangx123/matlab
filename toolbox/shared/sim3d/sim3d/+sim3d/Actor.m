classdef Actor < sim3d.AbstractActor

    properties ( Hidden )
        Material (1, 1) sim3d.internal.MaterialAttributes;
        Physical (1, 1) sim3d.internal.PhysicalAttributes;
        DynamicMesh (1, 1) sim3d.internal.DynamicMeshAttributes;
        Selected (1, 1) logical=false;
        UpdateImpl = [];
        OutputImpl = [];
    end


    properties
        % 保存参与者数据的结构，指定为结构体。
        % 可以更新和维护此数据，并在仿真期间或设置方法中使用它来更新结构的字段。
        UserData = [];
    end


    % 逻辑值，默认值为 false
    % 如果设置为 false，属性值将存储在对象中。
    % 如果为 true，属性值不存储在对象中。
    % set 和 get 函数无法通过使用属性名称对对象进行索引来访问属性。
    properties (Dependent)
        %% 网格属性
        Faces;                  % 每个三角形的顶点
        Vertices;               % 网格几何体的顶点
        Normals;                % 每个顶点的法线
        TextureCoordinates;     % 纹理坐标
        VertexColors;

        %% 材质属性
        Color;                  % 参与者的基色
        Transparency;           % 参与者的透明度，指定为 (0,1) 范围内的实正数，其中 0 表示不透明对象，1 表示完全透明对象。
        Shininess;              % 参与者的光泽度，指定为 (0,1) 范围内的实数正数，其中 0 表示不发光的对象，1 表示完全有光泽的对象。
        Metallic;               % 参与者的金属外观，指定为 (0,1) 范围内的实正数，其中 0 表示塑料表面，1 表示金属表面。
        Flat;                   % 参与者的平面着色因子，指定为 (0,1) 范围内的实正数，其中 0 表示光滑表面，1 表示多面表面。
        Tessellation;           % 参与者的细分因子，指定为 (0,8) 范围内的实正整数。使用此属性指定自动几何细化的系数。当使用纹理置换贴图时，此属性非常有用。
        VertexBlend;            % 顶点的颜色混合系数，指定为 (0,1) 范围内的正实数。这个值可以大一些，可以达到发光颜色的效果。
        Shadows;                % 参与者阴影
        Texture;                % 参与者形状的源文件，指定为字符数组。支持的文件类型包括 JPEG、PNG、BMP 和 TGA。文件路径应该是绝对路径。
        TextureMapping;         % 应用于参与者纹理的纹理映射参数，指定为正实数向量。用 TextureMapping 定义纹理混合、位移、凹凸因子和粗糙度。
        TextureTransform;       % 应用于参与者的纹理变换，指定为正实数标量。使用 TextureTransform 定义纹理位置、速度、比例和角度。

        %% 物理属性
        LinearVelocity;         % 局部坐标中参与者的线速度，指定为正实数向量，以米每秒为单位。
        AngularVelocity;        % 局部坐标中参与者的角速度，指定为正实数向量，以弧度每秒为单位。
        Mass;                   % 参与者的质量，指定为正实数标量，以千克为单位。
        CenterOfMass;           % sim3d.Actor 对象物体的质心 ，指定为正实数向量。使用此属性可将重心从局部坐标系的原点移动。
        Gravity;                % 对参与者施加重力，如果没有施加重力，则指定为 0 (false) ，如果施加重力，则指定为 1 (true)。
        Physics;                % 参与者对物理作用力的反应，指定为 0 (false) 或 1 (true)。如果 Physics 启用，则参与者独立于其父级参与者对象移动，但与其子级对象一起移动，除非子对象也启用 Physics。
        Collisions;             % 对象碰撞，如果没有碰撞，则指定为 0 (false)，如果对象将发生碰撞，则指定为 1 (true)。
        LocationLocked;         % 静止平移运动，指定为 0 (false) 或 1 (true)。如果启用此属性，参与者将固定在适当的位置。如果参与者定义了非零线速度，它就会与其他对象交互，就像它自己移动一样。可以使用此属性对带式输送机进行建模。
        RotationLocked          % 静止旋转运动，指定为 0 (false) 或 1 (true)。如果启用此属性，则 sim3d.Actor 对象将固定在合适的位置。如果参与者定义了一个非零角速度，它就会与其他对象交互，就像它自己移动一样。可以使用此属性对圆形传送带（转盘）进行建模。
    end


    properties (Dependent, Hidden)
        Inertia (1, 3) double;
        Force (1, 3) double;
        Torque (1, 3) double;
        ContinuousMovement( 1, 1 )logical;
        Friction( 1, 1 )double
        Restitution( 1, 1 )double;
        PreciseContacts( 1, 1 )logical;

        Masked( 1, 1 )logical;
        TwoSided( 1, 1 )logical;
        Refraction( 1, 1 )double;
        Hidden( 1, 1 )logical;
        ConstantAttributes( 1, 1 )logical;

        %% R2023a引入
        RequestMaterial     (1, 1) logical;
        RequestDynamicMesh  (1, 1) logical;
        RequestPhysical     (1, 1) logical;
        WorldTranslation    (1, 3) double{mustBeFinite};
        WorldRotation       (1, 3) double{mustBeFinite };
        WorldScale          (1, 3) double{mustBeFinite};
    end


    properties ( Access = protected )
        GenericActorSubscriber = [];
    end


    methods

        function self = Actor(varargin)
            sim3d.World.validateLicense();
            r = sim3d.Actor.parseInputs(varargin{:});
            actorName = r.ActorName;  % 参与者名称
            self@sim3d.AbstractActor(actorName, ...
                r.ParentActor, ...
                single(r.Translation), ...
                single(r.Rotation), ...
                single(r.Scale), ...
                'ActorClassId', uint16(r.ActorClassId), ...
                'Mesh', r.Mesh,  ...
                'Mobility', r.Mobility,  ...
                'Visibility', r.Visibility,  ...
                'HiddenInGame', r.HiddenInGame,  ...
                'SimulatePhysics', r.SimulatePhysics,  ...
                'EnableGravity', r.EnableGravity,  ...
                'CastShadow', r.CastShadow ...
                );
            self.OutputImpl = r.Output;
            self.UpdateImpl = r.Update;
            self.Material = sim3d.internal.MaterialAttributes(  );
            self.DynamicMesh = sim3d.internal.DynamicMeshAttributes(  );
            self.Physical = sim3d.internal.PhysicalAttributes(  );
            self.Physical.Mobility = r.Mobility;
        end

    end


    methods ( Access = public, Hidden )

        function setup( self )
            setup@sim3d.AbstractActor( self );
            self.GenericActorSubscriber = sim3d.io.Subscriber( self.getTag(  ) );
        end


        function reset( self )
            reset@sim3d.AbstractActor( self );
            self.write(  );
        end


        function output( self )
            if ~isempty( self.OutputImpl )
                self.OutputImpl( self );
            end
            self.write(  );
        end


        function update( self )
            if ~isempty( self.UpdateImpl )
                self.UpdateImpl( self );
            end
        end


        function actorType = getActorType( ~ )

            actorType = sim3d.utils.ActorTypes.BaseDynamic;
        end


        function actorS = getAttributes( self )
            actorS.Base = getAttributes@sim3d.AbstractActor( self );
            actorS.DynamicMesh = self.DynamicMesh.getAttributes(  );
            actorS.Material = self.Material.getAttributes(  );
            actorS.Physical = self.Physical.getAttributes(  );
            actorS.Selected = self.Selected;
        end


        function setAttributes( self, actorS )
            setAttributes@sim3d.AbstractActor( self, actorS.Base );
            self.DynamicMesh.setAttributes( actorS.DynamicMesh );
            self.Material.setAttributes( actorS.Material );
            self.Physical.setAttributes( actorS.Physical );
            self.Selected = actorS.Selected;
        end


        function translation = getTranslation(self)
            [ translation, ~, ~ ] = self.readTransform();
            if ~isempty( translation )
                self.Transform.setTranslation(translation);
            else
                translation = self.Transform.getTranslation();
            end
        end


        function rotation = getRotation(self)
            [ ~, rotation, ~ ] = self.readTransform();
            if ~isempty( rotation )
                self.Transform.setRotation(rotation);
            else
                rotation = self.Transform.getRotation();
            end
        end


        function scale = getScale(self)
            [ ~, ~, scale ] = self.readTransform();
            if ~isempty(scale)
                self.Transform.setScale(scale);
            else
                scale = self.Transform.getScale();
            end
        end


        function [ translation, rotation, scale ] = readTransform(self)

            if ~isempty(self.TransformReader)
                [ translation, rotation, scale ] = self.TransformReader.read();
            else
                translation = [];
                rotation = [];
                scale = [];
            end
        end


        function rotateAround(objs, Axis, Angle, Incremental)
            arguments
                objs (1, :) sim3d.Actor
                Axis (1, 3) double
                Angle (1, 1) double
                Incremental (1, 1)logical = true
            end

            for obj = objs
                Axis = sim3d.utils.Math.posToUnreal( Axis, 'vrml' );
                Ra = sim3d.utils.Math.mat2unr( sim3d.utils.Math.rotAA( Axis, Angle ) );
                if Incremental
                    Ru = sim3d.utils.Math.rot321( obj.Rotation );
                    obj.Rotation = sim3d.utils.Math.decomp321( Ra * Ru );
                else
                    obj.Rotation = sim3d.utils.Math.decomp321( Ra );
                end
            end
        end

    end


    methods ( Access = protected )

        function createGameActor( self )

            if ~isempty( self.ParentWorld ) && self.ParentWorld.IsMockWorld(  )
                self.CreateActor = MockUnrealActor( self );
            else
                createGameActor@sim3d.AbstractActor( self );
            end
            self.DynamicMesh.setup( self.Name );
            self.Material.setup( self.Name );
            self.Physical.setup( self.Name );
        end


        function write( self )
            self.DynamicMesh.publish(  );
            self.Material.publish(  );
            self.Physical.publish(  );
        end

    end

    methods

        function delete( self )
            delete@sim3d.AbstractActor( self );
            if ~isempty( self.GenericActorSubscriber )
                self.GenericActorSubscriber = [  ];
            end
        end


        % 复制另一个参与者的所有属性
        % doc sim3d.actor.copy
        function copy(self, other, CopyChildren, UseSourcePosition)
            arguments
                self (1, 1) sim3d.Actor
                other (1, 1) sim3d.Actor
                CopyChildren (1, 1) logical = true
                UseSourcePosition (1, 1) logical = false
            end

            self.DynamicMesh.copy(other.DynamicMesh);
            self.Physical.copy(other.Physical);
            self.Material.copy(other.Material);
    
            self.Selected = other.Selected;
    
            copy@sim3d.AbstractActor(self, other, CopyChildren, UseSourcePosition);
        end


        function createShape( objs, Type, varargin )
            arguments
                objs(1, :)sim3d.Actor
                Type(1, :)char
                
            end
            % 函数可以有一个Repeating arguments用于输入的块和一个用于输出的块。
            % 输入 Repeating参数块可以包含一个或多个重复参数，而Repeating输出参数块只能包含一个重复参数。
            % R36( Repeating )
            % varargin
            arguments (Repeating)
                varargin
            end
    
            for obj = objs
                Type = lower( Type );
                if any( contains( sim3d.utils.Geometry.AvailablePrimitives, Type ) )
                    [ V, N, F, T, C ] = sim3d.utils.Geometry.( Type )( varargin{ : } );
                    obj.createMesh( V, N, F, T, C );
                else
                    error( message( 'shared_sim3d:sim3dActor:methodnotfound', Type, 'sim3d.utils.Geometry' ) );
                end
            end
        end


        function createMesh( self, Vertices, Normals, Faces, TCoords, VColors )
            arguments
                self(1, :)sim3d.Actor
                Vertices(:, 3)double
                Normals(:, 3)double
                Faces(:, 3)double
                TCoords(:, 2)double = []
                VColors(:, 3)double = []
            end
    
            self.DynamicMesh.createMesh( Vertices, Normals, Faces, TCoords, VColors );
            self.DynamicMesh.IsValid = true;
        end


        function addMesh( self, Vertices, Normals, Faces, TCoords, VColors )
            arguments
                self(1, :)sim3d.Actor
                Vertices(:, 3)double
                Normals(:, 3)double
                Faces(:, 3)double
                TCoords(:, 2)double = []
                VColors(:, 3)double = []
            end
        
            self.DynamicMesh.addMesh( Vertices, Normals, Faces, TCoords, VColors );
            self.DynamicMesh.IsValid = true;
        end


        function load( objs, Source, varargin )
    
            for obj = objs
                if ischar( Source ) || isstring( Source )
                    Source = strtrim( char( Source ) );
                    if isfile( Source )
                        resolvedSource = Source;
                    else
                        resolvedSource = which( Source );
                    end
                    if isfile( resolvedSource )
                        [ ~, ~, ext ] = fileparts( resolvedSource );
                        if isempty( obj.ParentWorld ) && ( strcmpi( ext, '.f3d' ) ...
                                || strcmpi( ext, '.mat' ) ...
                                || strcmpi( ext, '.fbx' ) )
                            error( message( 'shared_sim3d:sim3dActor:LoadNotSupported', obj.getTag(  ) ) );
                        end
                        switch lower( ext )
                            case '.f3d'
                                sim3d.utils.Impex.importFromF3DFile( obj, resolvedSource, varargin{ : } );
                            case '.mat'
                                sim3d.utils.Impex.importFromMATFile( obj, resolvedSource );
                            case '.stl'
                                sim3d.utils.Impex.importSTL( obj, resolvedSource, varargin{ : } );
                            case { '.fbx', '.dae', '.sdf', '.urdf' }
                                wst = warning( 'off', 'sl3d:interface:engineerr' );
                                wcl = onCleanup( @(  )warning( wst ) );
                                [ ~, w ] = vrimport( resolvedSource, 'solid', strcmpi( ext, '.fbx' ) );
                                clear( 'wcl' );
                                sim3d.utils.Impex.importX3D( obj, w, varargin{ : } );
                            case { '.wrl', '.x3d', '.x3dv' }
                                sim3d.utils.Impex.importX3D( obj, resolvedSource, varargin{ : } );
                            otherwise
                                error( message( 'shared_sim3d:sim3dActor:UnsupportedFileImport', resolvedSource ) );
                        end
                    else
                        error( message( 'shared_sim3d:sim3dActor:FileNotFound', Source ) );
                    end
                elseif isobject( Source )
                    switch class( Source )
                        case 'matlab.graphics.primitive.Patch'
                            sim3d.utils.Impex.importPatch( obj, Source, varargin{ : } );
                        case 'matlab.graphics.chart.primitive.Surface'
                            sim3d.utils.Impex.importSurf( obj, Source, varargin{ : } );
                        case 'rigidBodyTree'
                            sim3d.utils.Impex.importRBT( obj, Source, varargin{ : } );
                        otherwise
                            error( message( 'shared_sim3d:sim3dActor:UnsupportedClassImport', class( Source ) ) );
                    end
                end
            end
        end


        function save( objs, FileName )
            isMultiple = numel( objs ) > 1;
            for obj = objs
    
                [ dir, file, ext ] = fileparts( char( FileName ) );
                if isempty( ext )
                    ext = '.mat';
                end
                if isMultiple
                    fileName = [ fullfile( dir, file ), '_', obj.Name, ext ];
                else
                    fileName = [ fullfile( dir, file ), ext ];
                end
    
                switch lower( ext )
                    case '.mat'
                        sim3d.utils.Impex.exportToMATFile( obj, fileName );
                    otherwise
                        error( message( 'shared_sim3d:sim3dActor:UnsupportedFileExport', FileName ) );
                end
            end
        end


        function propagate( self, PropName, PropValue, Condition )
            arguments
                self( 1, : )sim3d.AbstractActor
                PropName( 1, : )char
                PropValue
                Condition{ mustBeMember( Condition, { 'all', 'children', 'selected', 'unselected' } ) } = 'all'
            end
            propagate@sim3d.AbstractActor( self, PropName, PropValue, Condition );
        end


        function Result = gather( self, PropName, IncludeChildren )
    
            arguments
                self( 1, 1 )sim3d.AbstractActor
                PropName
                IncludeChildren( 1, 1 )logical = true
                end
            Result = gather@sim3d.AbstractActor( self, PropName, IncludeChildren );
            end
        end


    methods

        function faces = get.Faces( self )
            faces = self.DynamicMesh.Faces;
        end

        
        function set.Faces( self, faces )
            self.DynamicMesh.Faces = faces;
        end

        
        function vertices = get.Vertices( self )
            vertices = self.DynamicMesh.Vertices;
        end

        
        function set.Vertices( self, vertices )
            self.DynamicMesh.Vertices = vertices;
        end

        
        function normals = get.Normals( self )
            normals = self.DynamicMesh.Normals;
        end

        
        function set.Normals( self, normals )
            self.DynamicMesh.Normals = normals;
        end

        
        function textureCoordinates = get.TextureCoordinates( self )
            textureCoordinates = self.DynamicMesh.TextureCoordinates;
        end

        
        function set.TextureCoordinates( self, textureCoordinates )
            self.DynamicMesh.TextureCoordinates = textureCoordinates;
        end

        
        function vertexColors = get.VertexColors( self )
            vertexColors = self.DynamicMesh.VertexColors;
        end

        
        function set.VertexColors( self, vertexColors )
            self.DynamicMesh.VertexColors = vertexColors;
        end
        
        
        function color = get.Color( self )
            color = self.Material.Color;
        end

        
        function set.Color( self, color )
            self.Material.Color = color;
        end

        
        function masked = get.Masked( self )
            masked = self.Material.Masked;
        end

        
        function set.Masked( self, masked )
            self.Material.Masked = masked;
        end

        
        function transparency = get.Transparency( self )
            transparency = self.Material.Transparency;
        end

        
        function set.Transparency( self, transparency )
            self.Material.Transparency = transparency;
        end

        
        function twoSided = get.TwoSided( self )
            twoSided = self.Material.TwoSided;
        end

        
        function set.TwoSided( self, twoSided )
            self.Material.TwoSided = twoSided;
        end

        
        function set.Texture( self, texture )
            self.Material.Texture = texture;
        end

        
        function texture = get.Texture( self )
            texture = self.Material.Texture;
        end

        
        function shininess = get.Shininess( self )
            shininess = self.Material.Shininess;
        end

        
        function set.Shininess( self, shininess )
            self.Material.Shininess = shininess;
        end

        
        function textureMapping = get.TextureMapping( self )
            textureMapping = self.Material.TextureMapping;
        end
        
        function set.TextureMapping( self, textureMapping )
            self.Material.TextureMapping = textureMapping;
        end
        

        function textureTransform = get.TextureTransform( self )
            textureTransform = self.Material.TextureTransform;
        end
        
        function set.TextureTransform( self, textureTransform )
            self.Material.TextureTransform = textureTransform;
        end

        
        function metallic = get.Metallic( self )
            metallic = self.Material.Metallic;
        end

        
        function set.Metallic(self, metallic)
            self.Material.Metallic = metallic;
        end

        
        function refraction = get.Refraction( self )
            refraction = self.Material.Refraction;
        end

        
        function set.Refraction( self, refraction )
            self.Material.Refraction = refraction;
        end

        
        function flat = get.Flat(self)
            flat = self.Material.Flat;
        end

        
        function set.Flat(self, flat)
            self.Material.Flat = flat;
        end

        
        function tessellation = get.Tessellation(self)
            tessellation = self.Material.Tessellation;
        end

        
        function set.Tessellation(self, tessellation)
            self.Material.Tessellation = tessellation;
        end
        

        function vertexBlend = get.VertexBlend(self)
            vertexBlend = self.Material.VertexBlend;
        end
        

        function set.VertexBlend(self, vertexBlend)
            self.Material.VertexBlend = vertexBlend;
        end
        

        function shadows = get.Shadows(self)
            shadows = self.Material.Shadows;
        end

        
        function set.Shadows(self, shadows)
            self.Material.Shadows = shadows;
        end
        
        
        function linearVelocity = get.LinearVelocity(self)
            linearVelocity = self.Physical.LinearVelocity;
        end
        

        function set.LinearVelocity(self, linearVelocity)
            self.Physical.LinearVelocity = linearVelocity;
        end

        
        function angularVelocity = get.AngularVelocity(self)
            angularVelocity = self.Physical.AngularVelocity;
        end
        

        function set.AngularVelocity(self, angularVelocity)
            self.Physical.AngularVelocity = angularVelocity;
        end
        

        function mass = get.Mass(self)
            mass = self.Physical.Mass;
        end
        

        function set.Mass(self, mass)
            self.Physical.Mass = mass;
        end

        
        function inertia = get.Inertia(self)
            inertia = self.Physical.Inertia;
        end
        

        function set.Inertia(self, inertia)
            self.Physical.Inertia = inertia;
        end
        

        function force = get.Force(self)
            force = self.Physical.Force;
        end

        
        function set.Force(self, force)
            self.Physical.Force = force;
        end

        
        function torque = get.Torque(self)
            torque = self.Physical.Torque;
        end

        
        function set.Torque(self, torque)
            self.Physical.Torque = torque;
        end
        

        function CenterOfMass = get.CenterOfMass(self)
            CenterOfMass = self.Physical.CenterOfMass;
        end

        
        function set.CenterOfMass(self, CenterOfMass)
            self.Physical.CenterOfMass = CenterOfMass;
        end

        
        function gravity = get.Gravity(self)
            gravity = self.Physical.Gravity;
        end
        

        function set.Gravity(self, gravity)
            self.Physical.Gravity = gravity;
        end

        
        function physics = get.Physics(self)
            physics = self.Physical.Physics;
        end
        

        function set.Physics(self, physics)
            self.propagatePhysicsIfEmpty(physics);
        end

        
        function continuousMovement = get.ContinuousMovement(self)
            continuousMovement = self.Physical.ContinuousMovement;
        end

        
        function set.ContinuousMovement(self, continuousMovement)
            self.Physical.ContinuousMovement = continuousMovement;
        end

        
        function friction = get.Friction(self)
            friction = self.Physical.Friction;
        end
        
        
        function set.Friction(self, friction)
            self.Physical.Friction = friction;
        end

        
        function restitution = get.Restitution(self)
            restitution = self.Physical.Restitution;
        end
        

        function set.Restitution(self, restitution)
            self.Physical.Restitution = restitution;
        end
        

        function preciseContacts = get.PreciseContacts(self)
            preciseContacts = self.Physical.PreciseContacts;
        end

        
        function set.PreciseContacts(self, preciseContacts)
            self.Physical.PreciseContacts = preciseContacts;
        end

        
        function collisions = get.Collisions(self)
            collisions = self.Physical.Collisions;
        end

        
        function set.Collisions(self, collisions)
            self.propagateCollisionsIfEmpty(collisions);
        end

        
        function locationLocked = get.LocationLocked(self)
            locationLocked = self.Physical.LocationLocked;
        end

        
        function set.LocationLocked(self, locationLocked)
            self.Physical.LocationLocked = locationLocked;
        end

        
        function rotationLocked = get.RotationLocked(self)
            rotationLocked = self.Physical.RotationLocked;
        end

        
        function set.RotationLocked(self, rotationLocked)
            self.Physical.RotationLocked = rotationLocked;
        end

        
        function set.Hidden(self, hidden)
            self.Physical.Hidden = hidden;
        end

        
        function hidden = get.Hidden(self)
            hidden = self.Physical.Hidden;
        end

        
        function constantAttributes = get.ConstantAttributes(self)
            constantAttributes = self.Physical.ConstantAttributes;
        end

        
        function set.ConstantAttributes(self, constantAttributes)
            self.Physical.ConstantAttributes = constantAttributes;
        end


        function worldTranslation = get.WorldTranslation( self )
            worldTranslation = self.Physical.WorldTranslation;
        end

        
        function setGenericActorMobility(self, mobility)
            self.Physical.Mobility = mobility;
        end

    end


    methods (Access = private)
    
        function propagatePhysicsIfEmpty( self, physics )
            self.Physical.Physics = physics;
            if ~isempty( self.Children ) && isempty( self.Vertices )
                childList = struct2cell( self.Children );
                for i = 1:numel( childList )
                    childList{ i }.propagatePhysicsIfEmpty( physics );
                end
            end
        end

        
        function propagateCollisionsIfEmpty( self, collisions )
            self.Physical.Collisions = collisions;
            if ~isempty( self.Children ) && isempty( self.Vertices )
                childList = struct2cell( self.Children );
                for i = 1:numel( childList )
                    childList{ i }.propagateCollisionsIfEmpty( collisions );
                end
            end
        end

    end


    methods (Access = private, Static)
    
        % 解析 sim3d.Actor() 构造函数所传入的参数
        function r = parseInputs( varargin )
            defaultParams = struct(  ...
                'Translation', single( zeros( 1, 3 ) ),  ...
                'Rotation', single( zeros( 1, 3 ) ),  ...
                'Scale', single( ones( 1, 3 ) ),  ...
                'ParentActor', 'Scene Origin',  ...
                'ActorName', '',  ...
                'Mesh', '',  ...
                'ActorClassId', uint16(sim3d.utils.SemanticType.None),  ...  % 对象类别标识符的语义分割图
                'Mobility', int32( sim3d.utils.MobilityTypes.Static),  ...
                'Visibility', true,  ...
                'HiddenInGame', false,  ...
                'SimulatePhysics', false,  ...
                'EnableGravity', true,  ...
                'CastShadow', false,  ...
                'Output', [],  ...
                'Update', []);
            
            parser = inputParser;
            parser.addParameter('Translation', defaultParams.Translation);  % 相对平移
            parser.addParameter('Rotation', defaultParams.Rotation);        % 相对旋转
            parser.addParameter('Scale', defaultParams.Scale);              % 相对缩放
            parser.addParameter('ParentActor', defaultParams.ParentActor);
            parser.addParameter('ActorName', defaultParams.ActorName);
            parser.addParameter('Mesh', defaultParams.Mesh);
            parser.addParameter('ActorClassId', defaultParams.ActorClassId);
            parser.addParameter('Mobility', defaultParams.Mobility );
            parser.addParameter('Visibility', defaultParams.Visibility );
            parser.addParameter('HiddenInGame', defaultParams.HiddenInGame );
            parser.addParameter('SimulatePhysics', defaultParams.SimulatePhysics );
            parser.addParameter('EnableGravity', defaultParams.EnableGravity );
            parser.addParameter('CastShadow', defaultParams.CastShadow );
            parser.addParameter("Output", defaultParams.Output );
            parser.addParameter("Update", defaultParams.Update );
    
            parser.parse( varargin{ : } );
            r = parser.Results;
        end

    end

end


