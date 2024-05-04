import Sofa
import SofaRuntime
import os

def main():
    # Make sure to load all necessary libraries
    SofaRuntime.importPlugin("Sofa.Component.StateContainer")

    # Call the above function to create the scene graph
    root = Sofa.Core.Node("root")
    createScene(root)

    # Once defined, initialization of the scene graph
    Sofa.Simulation.init(root)


# Function called when the scene graph is being created
def createScene(root):

    root.addObject('RequiredPlugin', pluginName='CGALPlugin')

    node = root.addChild('node')

    node.addObject('MeshOBJLoader', name="loader",filename='Triangular_Membrane v0.obj')
    node.addObject('MeshGenerationFromPolyhedron', name="MeshGenerator", inputPoints='@loader.position', inputTriangles='@loader.triangles', inputQuads='@loader.quads', 
                   drawTetras='1', facetSize="20", facetApproximation="1", cellRatio="2", cellSize="40" )
    node.addObject('MechanicalObject', name="dofs", position="@MeshGenerator.outputPoints")
    node.addObject('TetrahedronSetTopologyContainer', name="topo", tetrahedra="@MeshGenerator.outputTetras")
    node.addObject('TetrahedronSetGeometryAlgorithms', template="Vec3d", name="GeomAlgo", drawTetrahedra="1", drawScaleTetrahedra="0.8")
    node.addObject('VTKExporter', filename='Triangular_Membrane v', edges='0', tetras='1', exportAtBegin='1')
        
    return root

