require 'optim'
require 'xlua'

function newConv1D(ifm, ofm, filtsz, gpu)
   local tconv = gpu and cudnn.TemporalConvolution(ifm, ofm, filtsz) or nn.TemporalConvolution(ifm, ofm, filtsz)
   return tconv
end

function newLinear(inputSz, outputSz)
   local linear = nn.Linear(inputSz, outputSz)
   linear.weight:normal():mul(0.01)
   linear.bias:zero()
   return linear
end

-- From the option list, pick one of [sgd, adagrad, adadelta, adam]
function optimMethod(opt)

   print('Trying to use optim method: ' .. opt.optim)
   local optmeth = nil

   local state = {
      learningRate = opt.eta,
      weightDecay = opt.decay
   }
   
   if opt.optim == 'sgd' then
      state.momentum = opt.mom
      optmeth = optim.sgd
   elseif opt.optim == 'adagrad' then
      optmeth = optim.adagrad
  elseif opt.optim == 'adadelta' then
      state.rho = 0.95
      state.eps = 1e-6
      optmeth = optim.adadelta
   elseif opt.optim == 'adam' then
      state.beta1 = opt.beta1 or 0.9
      state.beta2 = opt.beta2 or 0.999
      state.epsilon = opt.epsilon or 1e-8
      optmeth = optim.adam
   else
      print('Unknown optimization method ' .. opt.optim '. Using SGD with momentum')
      state.momentum = opt.mom
      opt.optim = 'sgd'
      optmeth = optim.sgd
   end
   return state, optmeth
end

-- Does this file exist
function exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

