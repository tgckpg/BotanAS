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
	import com.adobe.scenegraph.loaders.*;
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.geom.*;

///*
	public class PelletState implements btMotionState
	{
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		private var mNode:SceneNode;
		private static var sT:Matrix3D = new Matrix3D;
		private var mTbody:btTransform;
		private var mDelta:btVector3;
		
		// ======================================================================
		//	Getters and Setters
		// ----------------------------------------------------------------------
		
		//Bullet only calls the update of worldtransform for active objects
		public function setWorldTransform(W:btTransform):void
		{
			// node should not notify us of this change: unsubscribe body observer
			var b:IRigidBody = mNode.physicsObject;			
			mNode.physicsObject = null;
			
			var B:btTransform = new btTransform;
			B.set(W);
			B.origin.sub(mDelta);
			B.copyToMatrix3D(sT);
			mNode.transform = sT;

			// subscribe body observer
			mNode.physicsObject = b;
		}
		
		public function getWorldTransform(W:btTransform):void
		{
			W.copyFromMatrix3D(mNode.transform);
			W.origin.add(mDelta);
		}
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function PelletState( node:SceneNode, delta:btVector3=null):void
		{
			mNode = node;
			mDelta = new btVector3;
			if (delta) mDelta.set(delta);
			else mDelta.setZero();
		}
	}	
}
