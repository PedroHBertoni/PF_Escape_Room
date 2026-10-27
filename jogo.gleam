pub fn explorar(ambiente: Ambiente, _jogador: Jogador) -> String {
    let objetos_txt = list.map(ambiente.objetos, fn(obj) { obj.nome })
    let saidas_txt = list.map(ambiente.saidas, fn(s) { s })
    string.join([
        ambiente.descricao,
        "\nObjetos: " <> string.join(objetos_txt, ", "),
        "\nSaídas: " <> string.join(saidas_txt, ", "),
    ], "\n")
}

pub fn interagir(objeto: Objeto, jogador: Jogador) -> Jogador {
    objeto.interacao(jogador)
}

pub fn resolver_enigma(enigma: Enigma, resposta: String, jogador: Jogador) -> Jogador {
    case resposta == enigma.solucao {
        True -> enigma.efeito(jogador)
        False -> jogador
    }
}

pub fn pegar_objeto(
  objeto: objeto.Objeto,
  jogador_atual: jogador.Jogador,
) -> jogador.Jogador {
  objeto.interacao(jogador_atual)
}
