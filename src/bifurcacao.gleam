import sgleam/image
import sgleam/fill
import sgleam/style
import sgleam/stroke

pub type Direcao {
    Esquerda
    Frente
    Direita
}

pub type Placa {
    Placa(
        direcao: Direcao,
        estacao: String, 
    )
}

pub type Bifurcacao {
    Bifurcacao(
        numero: Int,
        placas: List(Placa),
        direcao_correta: Direcao,
    )
}

pub fn simbolo_direcao(direcao: Direcao) -> String {
    case direcao {
        Esquerda -> "<"
        Frente -> "^"
        Direita -> ">"
    }
}

pub fn posicao_placa(direcao: Direcao) -> Int {
    case direcao {
        Esquerda -> 90
        Frente -> 270
        Direita -> 450
    }
}

pub fn desenha_placa(placa: Placa) -> image.Image {
    let fundo = image.rectangle( 160, 100, style.join([fill.cornflowerblue, stroke.black, stroke.width(4)]))
    let simbolo = image.text(simbolo_direcao(placa.direcao), 42, fill.black)
    let nome = image.text(placa.estacao, 17, fill.black)
    let cena_simbolo = fundo |> image.place_image(80, 30, simbolo)
    cena_simbolo |> image.place_image(80, 75, nome)
}

pub fn posicionar_placas( placas: List(Placa), cena: image.Image) -> image.Image {
    case placas {
        [] -> cena
        [placa, ..resto] -> { let nova_cena = cena |> image.place_image(posicao_placa(placa.direcao), 85, desenha_placa(placa)) 
        posicionar_placas(resto, nova_cena) }
    }
}

///cria a imagem completa da bifurcação
pub fn desenha_bifurcacao(bifurcacao: Bifurcacao) -> image.Image {
    let cena = image.empty_scene(540, 170)
    posicionar_placas(bifurcacao.placas, cena)
}