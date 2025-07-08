/// Modelos para respostas das APIs do governo brasileiro

class GastoDirecto {
  final String? codigoOrgao;
  final String? nomeOrgao;
  final String? codigoUnidadeGestora;
  final String? nomeUnidadeGestora;
  final double? valor;
  final String? mesAno;
  final String? dataLancamento;

  GastoDirecto({
    this.codigoOrgao,
    this.nomeOrgao,
    this.codigoUnidadeGestora,
    this.nomeUnidadeGestora,
    this.valor,
    this.mesAno,
    this.dataLancamento,
  });

  factory GastoDirecto.fromJson(Map<String, dynamic> json) {
    return GastoDirecto(
      codigoOrgao: json['codigoOrgao']?.toString(),
      nomeOrgao: json['nomeOrgao']?.toString(),
      codigoUnidadeGestora: json['codigoUnidadeGestora']?.toString(),
      nomeUnidadeGestora: json['nomeUnidadeGestora']?.toString(),
      valor: _parseDouble(json['valor']),
      mesAno: json['mesAno']?.toString(),
      dataLancamento: json['dataLancamento']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class Convenio {
  final String? numeroConvenio;
  final String? objetoConvenio;
  final String? nomeProponente;
  final String? uf;
  final String? municipio;
  final double? valorConvenio;
  final String? situacao;
  final String? dataInicioVigencia;
  final String? dataFimVigencia;

  Convenio({
    this.numeroConvenio,
    this.objetoConvenio,
    this.nomeProponente,
    this.uf,
    this.municipio,
    this.valorConvenio,
    this.situacao,
    this.dataInicioVigencia,
    this.dataFimVigencia,
  });

  factory Convenio.fromJson(Map<String, dynamic> json) {
    return Convenio(
      numeroConvenio: json['numeroConvenio']?.toString(),
      objetoConvenio: json['objetoConvenio']?.toString(),
      nomeProponente: json['nomeProponente']?.toString(),
      uf: json['uf']?.toString(),
      municipio: json['municipio']?.toString(),
      valorConvenio: _parseDouble(json['valorConvenio']),
      situacao: json['situacao']?.toString(),
      dataInicioVigencia: json['dataInicioVigencia']?.toString(),
      dataFimVigencia: json['dataFimVigencia']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class EstabelecimentoSaude {
  final String? codigoCnes;
  final String? nomeFantasia;
  final String? razaoSocial;
  final String? uf;
  final String? municipio;
  final String? tipoUnidade;
  final String? naturezaOrganizacao;

  EstabelecimentoSaude({
    this.codigoCnes,
    this.nomeFantasia,
    this.razaoSocial,
    this.uf,
    this.municipio,
    this.tipoUnidade,
    this.naturezaOrganizacao,
  });

  factory EstabelecimentoSaude.fromJson(Map<String, dynamic> json) {
    return EstabelecimentoSaude(
      codigoCnes: json['codigoCnes']?.toString(),
      nomeFantasia: json['nomeFantasia']?.toString(),
      razaoSocial: json['razaoSocial']?.toString(),
      uf: json['uf']?.toString(),
      municipio: json['municipio']?.toString(),
      tipoUnidade: json['tipoUnidade']?.toString(),
      naturezaOrganizacao: json['naturezaOrganizacao']?.toString(),
    );
  }
}

class Municipio {
  final int? id;
  final String? nome;
  final Microrregiao? microrregiao;

  Municipio({
    this.id,
    this.nome,
    this.microrregiao,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'],
      nome: json['nome'],
      microrregiao: json['microrregiao'] != null 
          ? Microrregiao.fromJson(json['microrregiao'])
          : null,
    );
  }
}

class Microrregiao {
  final int? id;
  final String? nome;
  final Mesorregiao? mesorregiao;

  Microrregiao({
    this.id,
    this.nome,
    this.mesorregiao,
  });

  factory Microrregiao.fromJson(Map<String, dynamic> json) {
    return Microrregiao(
      id: json['id'],
      nome: json['nome'],
      mesorregiao: json['mesorregiao'] != null 
          ? Mesorregiao.fromJson(json['mesorregiao'])
          : null,
    );
  }
}

class Mesorregiao {
  final int? id;
  final String? nome;
  final UF? uf;

  Mesorregiao({
    this.id,
    this.nome,
    this.uf,
  });

  factory Mesorregiao.fromJson(Map<String, dynamic> json) {
    return Mesorregiao(
      id: json['id'],
      nome: json['nome'],
      uf: json['UF'] != null ? UF.fromJson(json['UF']) : null,
    );
  }
}

class UF {
  final int? id;
  final String? sigla;
  final String? nome;
  final Regiao? regiao;

  UF({
    this.id,
    this.sigla,
    this.nome,
    this.regiao,
  });

  factory UF.fromJson(Map<String, dynamic> json) {
    return UF(
      id: json['id'],
      sigla: json['sigla'],
      nome: json['nome'],
      regiao: json['regiao'] != null ? Regiao.fromJson(json['regiao']) : null,
    );
  }
}

class Regiao {
  final int? id;
  final String? sigla;
  final String? nome;

  Regiao({
    this.id,
    this.sigla,
    this.nome,
  });

  factory Regiao.fromJson(Map<String, dynamic> json) {
    return Regiao(
      id: json['id'],
      sigla: json['sigla'],
      nome: json['nome'],
    );
  }
}

class TaxaJuros {
  final String? data;
  final double? valor;

  TaxaJuros({
    this.data,
    this.valor,
  });

  factory TaxaJuros.fromJson(Map<String, dynamic> json) {
    return TaxaJuros(
      data: json['data']?.toString(),
      valor: _parseDouble(json['valor']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class Receita {
  final String? codigoReceita;
  final String? nomeReceita;
  final String? naturezaReceita;
  final double? valorArrecadado;
  final String? mesAno;
  final String? dataLancamento;

  Receita({
    this.codigoReceita,
    this.nomeReceita,
    this.naturezaReceita,
    this.valorArrecadado,
    this.mesAno,
    this.dataLancamento,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      codigoReceita: json['codigoReceita']?.toString(),
      nomeReceita: json['nomeReceita']?.toString(),
      naturezaReceita: json['naturezaReceita']?.toString(),
      valorArrecadado: _parseDouble(json['valorArrecadado']),
      mesAno: json['mesAno']?.toString(),
      dataLancamento: json['dataLancamento']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}