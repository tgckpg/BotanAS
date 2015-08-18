// ================================================================================
//
//	ADOBE SYSTEMS INCORPORATED
//	Copyright 2011 Adobe Systems Incorporated
//	All Rights Reserved.
//
//	NOTICE: Adobe permits you to use, modify, and distribute this file
//	in accordance with the terms of the license agreement accompanying it.
//
// ================================================================================
package com.adobe.scenegraph
{
	// ===========================================================================
	//	Imports
	// ---------------------------------------------------------------------------
	import com.adobe.pellet.collision.dispatch.*;
	import com.adobe.pellet.collision.phasebroad.*;
	import com.adobe.pellet.collision.phasenarrow.*;
	import com.adobe.pellet.collision.shapes.*;
	import com.adobe.pellet.dynamics.*;
	import com.adobe.pellet.dynamics.solver.*;
	import com.adobe.pellet.math.*;
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	public class PelletManager
	{
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		public    var priorTime:uint;
		public    var currentTime:int;
		protected var _fixed_dt:Number = 1/60;	// time step

		protected var _broadphase:btBroadphaseInterface;
		protected var _dispatcher:btCollisionDispatcher;
		protected var _solver:btConstraintSolver;
		protected var _collisionConfiguration:btDefaultCollisionConfiguration;
		protected var _defaultContactProcessingThreshold:Number = bt.BT_LARGE_FLOAT;
		
		public var _dynamicsWorld:btDiscreteDynamicsWorld;
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function PelletManager()
		{
			_collisionConfiguration = new btDefaultCollisionConfiguration();
			_dispatcher = new btCollisionDispatcher(_collisionConfiguration);
			
			var worldMin:btVector3 = new btVector3(-1000,-1000,-1000);
			var worldMax:btVector3 = new btVector3( 1000, 1000, 1000);
			_broadphase = new btAxisSweep3(worldMin,worldMax);
			_solver = new btSequentialImpulseConstraintSolver();
			_dynamicsWorld = new btDiscreteDynamicsWorld(_dispatcher,_broadphase,_solver,_collisionConfiguration);
			_dynamicsWorld.getSolverInfo().m_splitImpulse = 1;//true;
		}

		public function step( fixedTimeStep:Boolean = true ):void
		{
			if ( fixedTimeStep )
			{
				// step the simulation
				if (_dynamicsWorld)
					_dynamicsWorld.stepSimulation( _fixed_dt, 0 );
			}
			else
			{
				currentTime = getTimer();
				var dt:Number = ( currentTime - priorTime ) / 1000.0;
				
				// step the simulation
				if (_dynamicsWorld)
					_dynamicsWorld.stepSimulation( dt, 2 );

				priorTime = currentTime;
			}
		}
		
		public function stepWithSubsteps(dt:Number, steps:int):void
		{
			if (_dynamicsWorld) 
				_dynamicsWorld.stepSimulation(dt, steps, _fixed_dt);
		}

		
		// ======================================================================
		//	Methods: object creations
		// ----------------------------------------------------------------------
		public function createRigidBody( obj:SceneNode, mass:Number, shape:btCollisionShape ):btRigidBody
		{
			bt.assert((!shape || shape.shapeType != btBroadphaseNativeTypes.INVALID_SHAPE_PROXYTYPE));
			
			//rigidbody is dynamic if and only if mass is non zero, otherwise static
			var isDynamic:Boolean = (mass != 0.);
			
			var localInertia:btVector3 = new btVector3(0,0,0);
			if (isDynamic)
				shape.calculateLocalInertia(mass,localInertia);
			
			// PelletObjectState extends btMotionState that provides interpolation capabilities, and only synchronizes 'active' objects
			var state:PelletState = new PelletState(obj);
			var cInfo:btRigidBodyConstructionInfo = new btRigidBodyConstructionInfo( mass, state, shape, localInertia );			
			var body:PelletRigidBody = new PelletRigidBody(cInfo);
			body.setContactProcessingThreshold( _defaultContactProcessingThreshold );
			
			obj.physicsObject      = body;

			_dynamicsWorld.addRigidBody( body );

			return body;
		}
		
		/** creates a tetrahedron rigid body object */
		public function createRegularTetrahedron( radius:Number, material:Material = undefined, name:String = undefined, id:String = undefined ):SceneMesh
		{
			var obj:SceneMesh = MeshUtils.createRegularTetrahedron( radius, material, name, id );
			var shape:btConvexHullShape = new btConvexHullShape(MeshUtils.getLastConvexHull());
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}
		
		/** creates a box rigid body object */
		public function createBox( 
			sizeX:Number = 1, sizeY:Number = 1, sizeZ:Number = 1, 
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined ):SceneMesh
		{
			var obj:SceneMesh = MeshUtils.createBox( sizeX,sizeY,sizeZ, material, name, id );
			var shape:btBoxShape = new btBoxShape(new btVector3(sizeX/2,sizeY/2,sizeZ/2));
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}
		
		/** creates a cyninder rigid body object */
		public function createCylinder( 
			radius:Number, length:Number,
			uTess:uint = undefined, vTess:uint = undefined,
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined ):SceneNode
		{
			var obj:SceneNode = new SceneNode;
			var mesh:SceneMesh = MeshUtils.createCylinder( radius, length, uTess, vTess, material );
			obj.addChild( mesh );
			mesh.appendTranslation( 0, 0, -length/2 );
			
			var shape:btCylinderShapeZ = new btCylinderShapeZ(radius, length);
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}

		/** creates a cone rigid body object */
		public function createCone( 
			radius:Number, length:Number,
			uTess:uint = undefined, vTess:uint = undefined,
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined ):SceneNode
		{
			var obj:SceneNode = new SceneNode;
			var mesh:SceneMesh = MeshUtils.createCone( radius, radius*1e-5, length, uTess, vTess, material );
			obj.addChild( mesh );
			mesh.appendTranslation( 0, 0, -length/2 );

			var shape:btConeShapeZ = new btConeShapeZ(radius, length);
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}
		
		/** creates a sphere rigid body object */
		public function createSphere( 
			radius:Number,
			uTess:uint = undefined, vTess:uint = undefined,
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined ):SceneMesh
		{
			var obj:SceneMesh = MeshUtils.createSphere( radius, uTess, vTess, material, id );
			var shape:btSphereShape = new btSphereShape(radius);
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}
		
		/** creates a capsule rigid body object */
		public function createCapsule( 
			radius:Number, length:Number,
			uTess:uint = undefined, vTess:uint = undefined,
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined ):SceneNode
		{
			var obj:SceneNode = new SceneNode;
			var mesh:SceneMesh = MeshUtils.createCylinder( radius, length, uTess, vTess, material, id );
			mesh.appendTranslation( 0, 0, -length/2 );
			var sphere0:SceneMesh = MeshUtils.createSphere( radius, uTess, uTess, material, '', id );
			sphere0.appendTranslation( 0, 0, -length/2 );
			var sphere1:SceneMesh = MeshUtils.createSphere( radius, uTess, uTess, material, '', id );
			sphere1.appendTranslation( 0, 0, +length/2 );
			obj.addChild( mesh );
			obj.addChild( sphere0 );
			obj.addChild( sphere1 );
			
			var shape:btCapsuleShape = new btCapsuleShapeZ(radius, length);
			var mass:Number = 1;
			
			createRigidBody(obj, mass, shape as btCollisionShape);
			
			return obj;
		}
		
		/** create static triangle mesh object from vertices & indices */
		public function createStaticTriangleMesh( 
			numTriangles:int, triangleIndexBase:Vector.<uint>, 
			numVertices:int,  vertexBase:Vector.<Number>,
			material:Material = null, name:String = undefined, id:String = undefined ):SceneMesh
		{
			var indexVertexArray:btTriangleIndexVertexArray = new btTriangleIndexVertexArray( numTriangles, triangleIndexBase, numVertices, vertexBase );
			var obj:SceneMesh = MeshUtils.generateSceneMesh( numTriangles, triangleIndexBase, numVertices, vertexBase );
			
			var useQuantizedAabbCompression:Boolean = false;
			var shape:btBvhTriangleMeshShape = new btBvhTriangleMeshShape(indexVertexArray,useQuantizedAabbCompression);
			createRigidBody(obj, 0, shape);
			obj.physicsObject.collisionFlags |= btCollisionObject.CF_STATIC_OBJECT;
			
			return obj;
		}
		
		/** create static triangle mesh using MeshUtils.createFractalTerrain */
		public function createStaticFractalTerrainAsTriangleMesh( 
			uTess:int, vTess:int, 
			sizeX:Number, sizeZ:Number, heightScale:Number, 
			uMult:Number = 1.0, vMult:Number = 1.0, 
			material:Material = null, name:String = undefined, 
			id:String = undefined, 
			heightField:HeightField = null,
			seed:uint = 0
		):SceneMesh
		{
			var obj:SceneMesh = MeshUtils.createFractalTerrain( uTess,vTess, sizeX,sizeZ,heightScale, uMult,vMult, material, name, id, null, seed );
			var indices:Vector.<uint> = new Vector.<uint>;
			var vertices:Vector.<Number> = new Vector.<Number>;
			obj.getIndexVertexArrayCopyForAllElements(indices,vertices);
			var indexVertexArray:btTriangleIndexVertexArray = new btTriangleIndexVertexArray( indices.length/3, indices, vertices.length/3, vertices );

			var useQuantizedAabbCompression:Boolean = false;
			var shape:btBvhTriangleMeshShape = new btBvhTriangleMeshShape(indexVertexArray,useQuantizedAabbCompression);
			createRigidBody(obj, 0, shape);
			
			obj.physicsObject.collisionFlags |= btCollisionObject.CF_STATIC_OBJECT;
			
			return obj;
		}

		/** create static height field object using MeshUtils.createFractalTerrain */
		public function createStaticFractalTerrainAsHeightField( 
			uTess:int, vTess:int, 
			sizeX:Number, sizeZ:Number, heightScale:Number, 
			uMult:Number = 1.0, vMult:Number = 1.0, 
			material:Material = null, name:String = undefined, 
			id:String = undefined, 
			heightField:HeightField = null,
			seed:uint = 0
		):SceneMesh
		{
			var hfield:HeightField = new HeightField;	// temporary! ... will be gc'ed.
			var obj:SceneMesh = MeshUtils.createFractalTerrain( uTess,vTess, sizeX,sizeZ,heightScale, uMult,vMult, material, name, id, hfield, seed );
			var indices:Vector.<uint> = new Vector.<uint>;
			var vertices:Vector.<Number> = new Vector.<Number>;
			obj.getIndexVertexArrayCopyForAllElements(indices,vertices);
			var indexVertexArray:btTriangleIndexVertexArray = new btTriangleIndexVertexArray( indices.length/3, indices, vertices.length/3, vertices );
			
			var shape:btHeightfieldTerrainShape = new btHeightfieldTerrainShape(
				hfield.numPointsX, hfield.numPointsZ, 
				hfield.heights,	// array will be used by btHeightfieldTerrainShape
				1,				// heightScale
				-100,100,		// minHeight, maxHeight
				1,				// upAxis
				true);			// edge flip
			shape.setLocalScaling( hfield.tileSize, 1, hfield.tileSize );
			
			createRigidBody(obj, 0, shape);
			obj.physicsObject.collisionFlags |= btCollisionObject.CF_STATIC_OBJECT;
			
			return obj;
		}
		
		/** create a static plane using fractal terrain */
		public function createStaticInfinitePlane(
			sizeX:Number, sizeZ:Number, 
			uTess:int = undefined, vTess:int = undefined, 
			material:Material = null, 
			name:String = undefined, 
			id:String = undefined, 
			uScale:Number = 1, vScale:Number = 1, uOffset:Number = 0, vOffset:Number = 0
		):SceneMesh
		{
			var obj:SceneMesh = MeshUtils.createPlane( sizeX, sizeZ, uTess, vTess, material, name, id, uScale, vScale, uOffset, vOffset );
			var shape:btStaticPlaneShape = new btStaticPlaneShape( 0, 1, 0, 0);
			createRigidBody(obj, 0, shape as btCollisionShape);
			obj.physicsObject.collisionFlags |= btCollisionObject.CF_STATIC_OBJECT;
			return obj;
		}
	}
}
