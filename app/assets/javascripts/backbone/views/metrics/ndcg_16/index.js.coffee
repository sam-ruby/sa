#= require backbone/views/metrics/ndcg/index
#= require backbone/models/ndcg

class Searchad.Views.ONdcg16 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_ndcg_16')

class Searchad.Views.OMpr16 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_mpr_16')

class Searchad.Views.OPrec16 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_prec_16')

class Searchad.Views.ORec16 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_recall_16')
