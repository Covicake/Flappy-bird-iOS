//
//  GameScene.swift
//  FlappyBird
//
//  Created by Fernando García Hernández on 27/2/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import SpriteKit
import GameplayKit


    //Struct que almacena valores para las distintas categorias de objeto fisico
struct CategoriasColisiones{
    static let mosca: UInt32 = 0x1 << 1
    static let suelo: UInt32 = 0x1 << 2
    static let tubo: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Declaracion sprites y labels
    var mosca = SKSpriteNode()
    var tubo1 = SKSpriteNode()
    var tubo2 = SKSpriteNode()
    var parejaTubos = SKNode()
    var fondo = SKSpriteNode()
    var suelo = SKSpriteNode()
    var puntuacionLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var vidasRestantesLabel = SKLabelNode()
    
    //Declaracion variables y valores iniciales
    var puntuacion : Int = 0
    var play : Bool = false
    var muerto : Bool = false
    var vidas : Int = 3
    
    
    //Declaracion acciones
    var mover_y_eliminar = SKAction()
    
    
    //Cuando el usuario pierde una vida o partida y pulsa la pantalla, se llama esta función que elimina todos los nodos y acciones y vuelve a setupGame.
    func reiniciar(){
        removeAllActions()
        removeAllChildren()
        play = false
        setupGame()
        
        
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    
    //Crea todas las vistas e inicializa todo.
    func setupGame(){
        self.speed = 1 //El juego arranca (al perder, se para)
        
            //Añadir Puntuacion
        
        puntuacionLabel.fontName = "Helvetica"
        puntuacionLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2.15)
        puntuacionLabel.text = String(puntuacion)  //Valor almacenado en la variable "puntuacion"
        puntuacionLabel.zPosition = 1 //Delante de todo
        self.addChild(puntuacionLabel)  //Lo incluimos en la vista.
        
            //Añadir vidas restantes
        
        vidasRestantesLabel.fontName = "Helvetica"
        vidasRestantesLabel.position = CGPoint(x: -self.frame.width/2.5, y: self.frame.height/2.15)
        vidasRestantesLabel.zPosition = 1
        vidasRestantesLabel.text = "Vidas: \(vidas)"
        self.addChild(vidasRestantesLabel)
        
        
            //Añadir mosca
        
                //Crear las texturas a partir de las imágenes
        let moscaTextura1 = SKTexture(imageNamed: "fly1")
        let moscaTextura2 = SKTexture(imageNamed: "fly2")
        let moscaTextura3 = SKTexture(imageNamed: "fly3")
                //Crear la animacion
        let moscaAnimacion = SKAction.animate(with: [moscaTextura1, moscaTextura2, moscaTextura3], timePerFrame: 0.1)
        let aleteoMosca = SKAction.repeatForever(moscaAnimacion)
        
                //Añadir las texturas al SpriteNode y asignarle posición, animación y propiedades físicas.
        mosca = SKSpriteNode(texture: moscaTextura1)
        mosca.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mosca.run(aleteoMosca)
        mosca.physicsBody = SKPhysicsBody(circleOfRadius: moscaTextura1.size().height/2)
        mosca.physicsBody?.isDynamic = false
        mosca.physicsBody?.affectedByGravity = false
        
                //Añadir Categorias de Colision de mosca
        
        mosca.physicsBody?.categoryBitMask = CategoriasColisiones.mosca
        mosca.physicsBody?.collisionBitMask = CategoriasColisiones.suelo | CategoriasColisiones.tubo
        mosca.physicsBody?.contactTestBitMask = CategoriasColisiones.suelo | CategoriasColisiones.tubo
        mosca.zPosition = 0 //Delante de todo excepto la puntuación
        self.addChild(mosca)
        
        
        
            //Añadir Fondo
                //Crear la textura a partir de la imagen
        let fondoTextura = SKTexture(imageNamed: "bg4")
        
                //Crear la animacion
        let fondoAnimacion1 = SKAction.moveBy(x: -fondoTextura.size().width, y: 0, duration: 5)  //Desplazamiento horizontal
        let fondoAnimacion2 = SKAction.moveBy(x: fondoTextura.size().width, y: 0, duration: 0)  //Sustitución del vacío que deja el movimiento anterior
        let movimientoFondo = SKAction.repeatForever(SKAction.sequence([fondoAnimacion1, fondoAnimacion2]))  //Repetir para siempre la secuencia
        
        var i: CGFloat = 0
        let iteraciones = (self.frame.width / fondoTextura.size().width) + 1
        while i<iteraciones{
            fondo = SKSpriteNode(texture: fondoTextura) //Asignar la textura al nodo
            
                //Según la iteración en la que estemos (valor de i), se mostrará la imagen del fondo en una posición distinta
                //para i = 0, se creará al principio de la pantalla, para i = 1, se creará al principio de la siguiente pantalla...etc
            fondo.position = CGPoint(x: fondoTextura.size().width * i, y: 0)
            fondo.size.height = self.frame.height
            fondo.run(movimientoFondo)
            fondo.zPosition = -3 //Detrás de todo
            self.addChild(fondo)
            i += 1
        }
        
            //Añadir Suelo
        
        let sueloTextura = SKTexture(imageNamed: "ground")
                //Añadir animacion para el suelo. El funcionamiento es similar que para el fondo.
        let animacionSuelo1 = SKAction.moveBy(x: -sueloTextura.size().width, y: 0, duration: 2.5)
        let animacionSuelo2 = SKAction.moveBy(x: sueloTextura.size().width, y: 0, duration: 0)
        let movimientoSuelo = SKAction.repeatForever(SKAction.sequence([animacionSuelo1, animacionSuelo2]))
        
        var j = CGFloat(0)
        let iteracionesSuelo = (self.frame.width / sueloTextura.size().width) + 2
        while (j<iteracionesSuelo){
            suelo = SKSpriteNode(texture: sueloTextura)
            suelo.position = CGPoint(x: ((-self.frame.width/2) + (suelo.size.width/2) * j), y: -self.frame.height/2)
            suelo.run(movimientoSuelo)
            suelo.zPosition = 0 //Mismo plano que la mosca
            self.addChild(suelo)
            j += 1

        }
        
            //Añadir un suelo estático para apoyar la animación y para las colisiones.
        suelo = SKSpriteNode(texture: sueloTextura)
        
        
        suelo.position = CGPoint(x: -self.frame.width/2 + suelo.size.width/2, y: -self.frame.height/2)
        suelo.physicsBody = SKPhysicsBody(rectangleOf: suelo.size)
        suelo.physicsBody?.categoryBitMask = CategoriasColisiones.suelo
        suelo.physicsBody?.collisionBitMask = CategoriasColisiones.mosca
        suelo.physicsBody?.contactTestBitMask = CategoriasColisiones.mosca
        suelo.physicsBody?.affectedByGravity = false
        suelo.physicsBody?.isDynamic = false
        suelo.zPosition = -1 //Detrás del suelo animado
        self.addChild(suelo)

    }
    
    
    //Funcion para crear los tubos por pares y la física para la brecha que hay entre ellos (Que al pasar la mosca por el centro, debe sumarse un punto)
    
    func crearTubos(){
            //Creamos un nodo en el que estarán los dos tubos que forman cada obstáculo
        parejaTubos = SKNode()
        
            //Un sprite sin textura ni imagen para la brecha
        let ScoreNode = SKSpriteNode()
        
            //Definimos el espacio que hay entre los tubos. 90 pixeles de alto y 3 de ancho. Ubicado en el centro de la pantalla (Se moverá verticalmente la mismca cantidad aleatoria de píxeles que los tubos
        ScoreNode.size = CGSize(width: 3, height: 90)
        ScoreNode.position = CGPoint(x: self.frame.width/2, y: self.frame.midY)
        ScoreNode.physicsBody = SKPhysicsBody(rectangleOf: ScoreNode.size)
        
            //Definimos la física del espacio entre los tubos. No colisiona, pero sí detecta cuando algo entra en contacto con él.
        ScoreNode.physicsBody?.categoryBitMask = CategoriasColisiones.score
        ScoreNode.physicsBody?.collisionBitMask = 0
        ScoreNode.physicsBody?.contactTestBitMask = CategoriasColisiones.mosca
        ScoreNode.physicsBody?.affectedByGravity = false
        ScoreNode.physicsBody?.isDynamic = false
        ScoreNode.zPosition = 50
        ScoreNode.color = SKColor.blue    //Por si quiere visualizarse la linea que debe atravesarse para sumar un punto.
        
            //Cargamos las imagenes de los tubos
        let tuboArriba = SKSpriteNode(imageNamed: "Tubo2")
        let tuboAbajo = SKSpriteNode(imageNamed: "Tubo1")
        
        
            //TUBO 1
        
        tuboArriba.position = CGPoint(x: self.frame.width/2, y: self.frame.midY + 345)  //Sumamos 345 para crear la brecha. En el tuboAbajo restaremos la misma cifra para hacerlo simétrico.
        
                //Física tubo 1.
        
        tuboArriba.physicsBody = SKPhysicsBody(rectangleOf: tuboArriba.size)
        
        tuboArriba.physicsBody?.categoryBitMask = CategoriasColisiones.tubo  //Es de tipo "tubo"
        tuboArriba.physicsBody?.collisionBitMask = CategoriasColisiones.mosca  //Colisiona con objetos físicos de tipo "mosca"
        tuboArriba.physicsBody?.contactTestBitMask = CategoriasColisiones.mosca
        tuboArriba.physicsBody?.isDynamic = false
        tuboArriba.physicsBody?.affectedByGravity = false
        
            //TUBO 2
        
        tuboAbajo.position = CGPoint(x: self.frame.width/2, y: self.frame.midY - 345)
        
                //Física tubo 2.
        
        tuboAbajo.physicsBody = SKPhysicsBody(rectangleOf: tuboAbajo.size)
        
        tuboAbajo.physicsBody?.categoryBitMask = CategoriasColisiones.tubo  //Tipo tubo
        tuboAbajo.physicsBody?.collisionBitMask = CategoriasColisiones.mosca  //Colisiona con tipo mosca
        tuboAbajo.physicsBody?.contactTestBitMask = CategoriasColisiones.mosca
        tuboAbajo.physicsBody?.isDynamic = false
        tuboAbajo.physicsBody?.affectedByGravity = false
        
            //Añadimos ambos tubos y la brecha a un nodo
        
        parejaTubos.addChild(tuboArriba)
        parejaTubos.addChild(tuboAbajo)
        parejaTubos.addChild(ScoreNode)
        
        parejaTubos.zPosition = -1  //Detrás del suelo animado
        parejaTubos.position.y += CGFloat.random(min: -200, max: 200)  //Desplazamos verticalmente los tubos aleatoriamente entre -200 y 200 píxeles.
        parejaTubos.run(mover_y_eliminar) //Ejecutamos la acción "mover_y_eliminar" que hace que los tubos se desplacen y, al llegar al final de la pantalla, se eliminen.
        parejaTubos.yScale = CGFloat(2) //Hacemos más grande el conjunto de los tubos más grande en el eje Y para que al desplazarlos verticalmente no queden
                                                //huecos por encima y por debajo
        
        //Añadimos dicho nodo a la vista
        self.addChild(parejaTubos)
    }
    
    
        //Funcion para actuar según las colisiones que se generen
    func didBegin(_ contact: SKPhysicsContact) {
        let primerCuerpo = contact.bodyA
        let segundoCuerpo = contact.bodyB
        
            //Colision entre mosca y espacio entre tubos Y VICEVERSA
        
        if ((primerCuerpo.categoryBitMask == CategoriasColisiones.mosca && segundoCuerpo.categoryBitMask == CategoriasColisiones.score) || (primerCuerpo.categoryBitMask == CategoriasColisiones.score && segundoCuerpo.categoryBitMask == CategoriasColisiones.mosca)){
            
            puntuacion += 1 //Suma un punto
            puntuacionLabel.text = "\(puntuacion)"  //Actualiza el label.
        }
        
            //Colision entre mosca y (tubos o suelo) o colision entre (tubos o suelo) y mosca
        
        if ((primerCuerpo.categoryBitMask == CategoriasColisiones.mosca && (segundoCuerpo.categoryBitMask == CategoriasColisiones.suelo) || (segundoCuerpo.categoryBitMask == CategoriasColisiones.tubo)) || ((primerCuerpo.categoryBitMask == CategoriasColisiones.suelo) || (primerCuerpo.categoryBitMask == CategoriasColisiones.tubo)) && segundoCuerpo.categoryBitMask == CategoriasColisiones.mosca){
                self.speed = 0  //Detenemos las acciones

                mosca.physicsBody?.categoryBitMask = 0  //Evitamos que la mosca siga colisionando con el suelo si ha caído
                vidas -= 1 //Restamos una vida
                if (vidas < 0) {  //Si se han perdido 3 significa que se ha perdido la partida, por tanto se muestra el pertinente mensaje con la puntuacion total.
                    gameOverLabel.fontName = "Helvetica"
                    gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                    gameOverLabel.text = "Has perdido :( Puntuacion total: \(puntuacion)"
                    gameOverLabel.zPosition = 3
                    self.addChild(gameOverLabel)
                    puntuacion = 0 //Se reinicia la puntuacion a 0
                    vidas = 3 //Se reinician las vidas a 3.
                }else{ //Si aun quedan vidas, entonces se muestra un mensaje indicando que se perdio una vida.
                    gameOverLabel.fontName = "Helvetica"
                    gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                    gameOverLabel.text = "Has perdido una vida. Pulsa para continuar"
                    gameOverLabel.zPosition = 3
                    self.addChild(gameOverLabel)
                }
                muerto = true  //Esta variable booleana será marcador para "touchesBegan".
        }
        
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (muerto == true){  //Si muerto es true, lo ponemos a false y llamamos a la funcion "reiniciar".
            
            muerto = false
            reiniciar()
            
        }else if (play == false){  //Si aun no se habia comenzado a jugar...
            play = true  //Indicamos que ya se comenzó a jugar
            
            mosca.physicsBody?.affectedByGravity = true  //Al iniciar el juego, la mosca empieza a ser afectada por la gravedad
            mosca.physicsBody?.isDynamic = true
            
            let aparicionTubos = SKAction.run({
                () in
                self.crearTubos()
                })  //Creamos una acción para crear los tubos.
            
            let tiempo_entre_tubos = SKAction.wait(forDuration: 2) //Creamos acción para esperar 2 segundos entre cada creación de tubos.
            
            self.run(SKAction.repeatForever(SKAction.sequence([aparicionTubos, tiempo_entre_tubos])))  //Se crea la repetición infinita de la secuencia en ese orden: Crear, esperar.
            
            
                //Acción para mover los tubos hasta el borde izquierdo de la pantalla.
            let moverTubos = SKAction.moveBy(x: -self.frame.width + parejaTubos.frame.width, y: 0, duration: TimeInterval(0.004 * (self.frame.width + parejaTubos.frame.width)))
                //Acción para eliminar los tubos. Si se ejecuta justo al finalizar la acción anterior, los tubos se eliminan cuando salen de la pantalla.
            let eliminarTubos = SKAction.removeFromParent()
            mover_y_eliminar = SKAction.sequence([moverTubos, eliminarTubos])  //Se crea la secuencia. Se ejecuta desde el nodo "parejaTubos" al final de la funcion "crearTubos".
            
            
        }else{
            //Si ya ha comenzado el juego, al pulsar la pantalla a mosca obtendrá un impulso hacia arriba.
            mosca.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            mosca.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
