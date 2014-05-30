#= require backbone/views/metrics/ndcg/index
#= require backbone/models/ndcg

class Searchad.Views.ONdcg1 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_ndcg_1')

class Searchad.Views.OMpr1 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_mpr_1')

class Searchad.Views.OPrec1 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_prec_1')

class Searchad.Views.ORec1 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_recall_1')
