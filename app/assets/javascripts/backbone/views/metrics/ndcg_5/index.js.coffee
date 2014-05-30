#= require backbone/views/metrics/ndcg/index
#= require backbone/models/ndcg

class Searchad.Views.ONdcg5 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_ndcg_5')

class Searchad.Views.OMpr5 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_mpr_5')

class Searchad.Views.OPrec5 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_prec_5')

class Searchad.Views.ORec5 extends Searchad.Views.ONdcg
  initialize: (options) =>
    super('o_recall_5')
