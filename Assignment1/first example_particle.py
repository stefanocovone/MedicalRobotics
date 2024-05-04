import Sofa
import Sofa.Core
from stlib3.scene import MainHeader 				


USE_GUI = True

def createScene(rootNode):
 

#adding all required sofa solvers 
    pluginList = ["Sofa.Component.AnimationLoop",
                  "Sofa.Component.Mass",				#needed to use [uniformMass]
                  "Sofa.Component.MechanicalLoad",			#needed to use [constant ForceField]
                  "Sofa.Component.StateContainer",			#needed to use [Mechanical Object]
                  "Sofa.Component.LinearSolver.Iterative",		#needed to use [cglinearSolver]        
                  "Sofa.Component.ODESolver.Backward",		#needed to use [eulerImplicitsolver]
                  "Sofa.Component.Visual",
                  "Sofa.GL.Component.Rendering3D"]


    MainHeader(rootNode, gravity=[0.0, 0.0, 0.0], dt = 0.01, plugins=pluginList)
    rootNode.addObject("FreeMotionAnimationLoop")
    rootNode.addObject('GenericConstraintSolver',maxIterations=1000,tolerance=0.001)

#### object1: particle

    particle = rootNode.addChild("particle")
      
    particle.addObject('EulerImplicitSolver', name='IntegScheme')			                     #integration scheme
    particle.addObject('CGLinearSolver', name='Solver', iterations=200, tolerance=1e-09, threshold=1e-09) #ODE solver iterativo
    
      
    particle.addObject('MechanicalObject', template="Rigid3", position= [0 ,0, 0,  0, 0, 0, 1], showObject="1")   #object type: rigid or deformable
    particle.addObject('UniformMass', name="mass", totalMass= 1.0)                         #properties: mass
    particle.addObject('ConstantForceField', totalForce=[1, 0, 0, 0, 0, 0])
    particle.addObject('UncoupledConstraintCorrection')				  
    
   

    return rootNode

