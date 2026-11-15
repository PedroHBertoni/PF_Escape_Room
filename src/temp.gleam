import gleam/list

//
// objeto.gleam
//
pub type Objeto {
  Objeto(
    nome: String,
    descricao: String,
    interacao: fn(Jogador) -> Jogador,
    estado: Estado,
  )
}

pub type Estado {
  Disponivel
  Indisponivel
  Quebrado(ferramenta: String, novo_estado: Estado)
  Coletavel
  Coletado
}

// Retorna a descricao de *obj* para o jogador
pub fn examinar(obj: Objeto) -> String {
  obj.descricao
  <> case obj.estado {
    Disponivel -> " - Esse objeto pode ser útil."
    Indisponivel -> " - Ja foi utilizado."
    Quebrado(_, _) -> " - Precisa ser consertado."
    Coletavel -> " - Pode ser coletado."
    Coletado -> " - Presente no inventario."
  }
}

// Atualiza o estado de um *obj*
pub fn atualizar_estado(obj: Objeto, novo_estado: Estado) -> Objeto {
  Objeto(..obj, estado: novo_estado)
}

// Executa a interacao definida pelo *obj*
pub fn interagir(obj: Objeto, player: Jogador) -> Jogador {
  obj.interacao(player)
}

// Retorna um tipo com *nome* se esse está presente
fn buscar_objeto(lista: List(Objeto), nome: String) -> Result(Objeto, Nil) {
  case lista {
    [] -> Error(Nil)
    [prim, ..resto] ->
      case prim.nome == nome {
        True -> Ok(prim)
        False -> buscar_objeto(resto, nome)
      }
  }
}

// Interação específica
// Coloca um *obj* no inventario do *player*
pub fn acao_coletar(nome_obj: String) -> fn(Jogador) -> Jogador {
  fn(player) { adicionar_obj(player, nome_obj) }
}

// Cria uma funcao de leitura de mensagem com *pista*
pub fn acao_ler_mensagem(pista: String) -> fn(Jogador) -> Jogador {
  fn(player) { adicionar_pista(player, pista) }
}

// Interação específica
// Faz um *obj* quebrado se tornar Disponivel
pub fn consertar(obj: Objeto, player: Jogador) -> Objeto {
  case obj.estado {
    Quebrado(ferramenta, novo_estado) -> {
      case possui_obj(player, ferramenta) {
        True -> atualizar_estado(obj, novo_estado)
        False -> obj
      }
    }
    _ -> obj
  }
}

// 
// jogador.gleam
//
pub type Jogador {
  Jogador(
    nome: String,
    local: String,
    inventario: List(String),
    pistas: List(String),
  )
}

// Adiciona um *obj*, pelo seu nome, ao inventario
pub fn adicionar_obj(player: Jogador, obj: String) -> Jogador {
  case possui_obj(player, obj) {
    True -> player
    False ->
      Jogador(..player, inventario: list.append(player.inventario, [obj]))
  }
}

// Remove *obj*, pelo seu nome, do inventario
pub fn gastar_obj(player: Jogador, obj: String) -> Jogador {
  Jogador(
    ..player,
    inventario: list.filter(player.inventario, fn(x) { x != obj }),
  )
}

// Registra uma *pista* descoberta
pub fn adicionar_pista(player: Jogador, pista: String) -> Jogador {
  case possui_pista(player, pista) {
    True -> player
    False -> Jogador(..player, pistas: list.append(player.pistas, [pista]))
  }
}

// Verifica se o *player* possui determinado *obj*
pub fn possui_obj(player: Jogador, obj: String) -> Bool {
  lista_contem(player.inventario, obj)
}

// Verifica se o *player* ja descobriu determinada *pista*
pub fn possui_pista(player: Jogador, pista: String) -> Bool {
  lista_contem(player.pistas, pista)
}

// Verifica se um elemento aparece em uma lista
fn lista_contem(lista: List(String), nome: String) -> Bool {
  case lista {
    [] -> False
    [prim, ..resto] ->
      case prim == nome {
        True -> True
        False -> lista_contem(resto, nome)
      }
  }
}

// Atualiza a localizacao do *player*
pub fn mudar_local(player: Jogador, novo_loc: String) -> Jogador {
  Jogador(..player, local: novo_loc)
}

pub fn reset_total(player: Jogador) -> Jogador {
  Jogador(..player, inventario: [], pistas: [])
}

import sgleam/check

pub fn jogador_examples() {
  let player =
    Jogador(nome: "Pedro", local: "Estacao Central", inventario: [], pistas: [])

  //
  // Teste de adicionar e remover objeto
  let player_com_obj = adicionar_obj(player, "Pe de cabra")
  let player_sem_obj = gastar_obj(player_com_obj, "Pe de cabra")
  check.eq(player_com_obj.inventario, ["Pe de cabra"])
  check.eq(possui_obj(player_com_obj, "Pe de cabra"), True)
  check.eq(player_sem_obj.inventario, [])

  // Teste de adicionar pista
  let player_com_pista = adicionar_pista(player, "A chave esta na secretaria.")
  check.eq(player_com_pista.pistas, ["A chave esta na secretaria."])
  check.eq(possui_pista(player_com_pista, "A chave esta na secretaria."), True)

  // Teste de evitar pistas duplicadas
  let player_pista_repetida =
    adicionar_pista(player_com_pista, "A chave esta na secretaria.")
  check.eq(player_pista_repetida.pistas, ["A chave esta na secretaria."])

  // Teste de deslocamento
  let player_movido = mudar_local(player, "Cabine")
  check.eq(player_movido.local, "Cabine")

  let player = reset_total(player_com_obj)
  check.eq(player.inventario, [])
  check.eq(player.pistas, [])
}

//
//
//
pub fn objeto_examples() {
  let player =
    Jogador(nome: "Pedro", local: "Secretaria", inventario: [], pistas: [])
  let chave_de_fenda =
    Objeto(
      nome: "Chave de Fenda",
      descricao: "Uma ferramenta de conserto.",
      interacao: acao_coletar("Chave de fenda"),
      estado: Coletavel,
    )
  let fax =
    Objeto(
      nome: "Fax",
      descricao: "Um aparelho quebrado sobre a mesa.",
      interacao: fn(player) { player },
      estado: Quebrado("Chave de fenda", Disponivel),
    )
  let mensagem =
    Objeto(
      nome: "Mensagem do fax",
      descricao: "Um documento impresso pelo fax.",
      interacao: acao_ler_mensagem("Verifique o armario da plataforma."),
      estado: Disponivel,
    )

  //
  // Teste de interacao com objeto (pegar)
  let player_apos_coleta = interagir(chave_de_fenda, player)
  check.eq(player_apos_coleta.inventario, ["Chave de fenda"])

  // Teste de interacao com objeto (consertar)
  let fax_consertado = consertar(fax, player_apos_coleta)
  check.eq(fax_consertado.estado, Disponivel)
  let fax_ainda_quebrado = consertar(fax, player)
  check.eq(fax_ainda_quebrado.estado, Quebrado("Chave de fenda", Disponivel))

  // Teste de interacao com objeto (ler mensagem)
  let player_apos_leitura = interagir(mensagem, player)
  check.eq(player_apos_leitura.pistas, ["Verifique o armario da plataforma."])
}
