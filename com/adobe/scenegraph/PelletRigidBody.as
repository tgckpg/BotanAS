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
	import com.adobe.pellet.dynamics.*;
	import com.adobe.pellet.math.*;
	
	import flash.geom.*;
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	public class PelletRigidBody extends btRigidBody implements IRigidBody
	{
		// ======================================================================
		//	Getters and Setters
		// ----------------------------------------------------------------------
		public function set mass( v:Number ):void
		{
			this.setMass( v );
		}
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function PelletRigidBody( constructionInfo:btRigidBodyConstructionInfo )
		{
			super( constructionInfo );
		}

		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
//		private static const _btt_:btTransform = new btTransform();		
//		override public function set transform( m:Matrix3D ):void
//		{
//			_btt_.copyFromMatrix3D( m );
//			setCenterOfMassTransform( _btt_ );
//		}
		
		public function updateTransform():void
		{
			var w:btTransform = new btTransform();
			getMotionState().getWorldTransform( w );
			// TODO: verify for static/kinematic objects: see comment in btRigidBody set transform
			setCenterOfMassTransform( w );
		}
		
		private static const _v_:Vector3D = new Vector3D();
		public function getLinearVelocity( result:Vector3D = null ):Vector3D
		{
			if ( !result )
				result = _v_;
				
			result.x = m_linearVelocity.x;
			result.y = m_linearVelocity.y;
			result.z = m_linearVelocity.z;
			
			return result;
		}
		
		private static const _btv_:btVector3 = new btVector3();
		public function applyImpulseToCenter( x:Number, y:Number, z:Number ):void
		{
			_btv_.x = x;
			_btv_.y = y;
			_btv_.z = z;
			super.applyCentralImpulse( _btv_ );
		}
		
		public function setWorldTransformBasis( matrix:Matrix3D ):void
		{
			worldTransform.basis.copyFromMatrix3D( matrix );
		}
	}
}