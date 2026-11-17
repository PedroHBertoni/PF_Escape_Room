///tipo que representa uma porta. Essa implementação vai ser utilizada no enigma 2.
pub type Porta {
    Porta(
        nome: String,
        descricao: String,
        ferramenta_necessaria: String,
        estado: EstadoPorta,
    )
}

///tipo que representa o estado da porta
pub type EstadoPorta {
    Trancada
    Aberta
}

///função de abrir a porta. Se ela estiver tracada e o jogador tiver a have correspondente da porta, ela é aberta. Se não, ela continua trancada
pub fn abrir_porta(porta: Porta, ferramenta: String) -> Porta {
    case porta.estado {
        Aberta -> porta
        Trancada -> {
            case ferramenta == porta.ferramenta_necessaria {
                True -> Porta(..porta, estado: Aberta)
                False -> porta
            }
        }
    }
}