### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 87e2af94-93df-11eb-3e9e-4bcb05b5c6dc
begin
	using Flux: Data.DataLoader
	using Flux: onehotbatch, onecold, crossentropy, flatten
	using Flux: @epochs
	using Flux
	using MLDatasets
	using Pkg
end

# ╔═╡ 87cac48a-93df-11eb-031d-8b4cebe1282e
md"""
### Learning How to Use _Flux_

Following write-up by [Artur Jugas](https://towardsdatascience.com/deep-learning-with-julia-flux-jl-story-7544c99728ca) which uses the classic MNIST character classification dataset.

Bring packages into local scope:
"""

# ╔═╡ 87eff10c-93df-11eb-224e-19ac8c577709
md"Load the MNIST dataset:"

# ╔═╡ 880b6934-93df-11eb-372e-a79e1acbcfa0
begin
	x_train_raw, y_train_raw = MNIST.traindata()
	x_valid_raw, y_valid_raw = MNIST.testdata()
end;

# ╔═╡ 882522cc-93df-11eb-072a-b5e085c0a06d
md"Add the channel layer:"

# ╔═╡ 883654c8-93df-11eb-19c0-bb9a4d9ea1e0
begin
	x_train = Flux.unsqueeze(x_train_raw, 3)
	x_valid = Flux.unsqueeze(x_valid_raw, 3)
end;

# ╔═╡ 88379928-93df-11eb-2ea9-4deb244af06b
md"Encode output labels"

# ╔═╡ 88469704-93df-11eb-2329-2de5ece4d939
begin
	y_train = onehotbatch(y_train_raw, 0:9)
	y_valid = onehotbatch(y_valid_raw, 0:9)
end;

# ╔═╡ 8853c08a-93df-11eb-3a6c-ebf587191d94
md"Create full dataset:"

# ╔═╡ 8866cc48-93df-11eb-095e-fb50745e050b
test_train_data = DataLoader((x_train, y_train), batchsize=128);

# ╔═╡ 8868630a-93df-11eb-2389-af9749856a19
md"""
**_Now we need to build the model !_**

---

Some of the key model characteristics are:

`pad` -> parameter that adds extra 'padding' to image (2d-array) recieved by the convolution layer ie. it adds extra cells around the input array.

`stride` -> parameter that controls the increments in which a convolutional layers moves across the input image (2d-array) recieved by the layer.

`relu` & `softmax` -> are two types of activation functions, these decide the behaviour of the artificial neuron firing/activation in the network.
"""

# ╔═╡ 88a7917e-93df-11eb-1206-f31e48b1314b
begin
	test_model = Chain(
		# 28x28 => 14x14 conv. layer
		Conv((5, 5), 1=>8, pad=2, stride=2, relu),
		# 14x14 => 7x7 conv. layer
		Conv((3, 3), 8=>16, pad=1, stride=2, relu),
		# 7x7 => 4x4 conv. layer
		Conv((3, 3), 16=>32, pad=1, stride=2, relu),
		# 4x4 => 2x2 conv. layer
		Conv((3, 3), 32=>32, pad=1, stride=2, relu),
		
		# average pooling on each width x height feature map
		GlobalMeanPool(),
		flatten,
		
		# dense output layer, softmax activation
		Dense(32, 10),
		softmax
	)
end

# ╔═╡ 88dc844c-93df-11eb-0456-cb4a6bf00391
md"We can obtain predictions to check if `test_model` has been constructed properly. These predictions are meaningless, since the model has not yet been trained."

# ╔═╡ 8946f264-93df-11eb-307b-f51da5bedae6
begin
	# get encoded predictions
	ŷ_encoded = test_model(x_train)
	
	# decode predictions
	ŷ = onecold(ŷ_encoded)
end

# ╔═╡ 89615226-93df-11eb-3f2b-fb0999cc5a56
md"""
At this point, we have checked that our model: `test_model`, has been properly set up.

---

The next step will be to train the model.
For this, we will need to decide how to update the model parameters and find a way to measure its performance.

We define an __accuracy metric__ function which takes parameters: `ŷ` which is the models prediction, and `y` which is the ground-truth:
```julia
test_accuracy(ŷ, y) = mean(onecold(ŷ) .== onecold(y))
```

The `crossentropy` __loss function__ we use is provided by _Flux_.
"""

# ╔═╡ 89910b88-93df-11eb-3edb-3f6e11ddb643
begin
	# accuracy function definition
	test_accuracy(ŷ, y) = mean(onecold(ŷ) .== onecold(y))
	
	# loss function definition
	test_loss(x, y) = Flux.crossentropy(test_model(x), y)
end

# ╔═╡ 89cbbe40-93df-11eb-283a-69cef1cda710
md"Next, we define the rate at which the model will learn and store the model in a variable to be able to tune them later.

We also set the optimser to __gradient descent__, better choices such as: `ADAM` or `Momentum` exits, but `Descent` is good enough for this simple model."

# ╔═╡ 8a4b8dfa-93df-11eb-0ea9-8985a3f3049c
begin
	# learning rate
	test_learn_rate = 0.1
	test_optimiser 	= Descent(test_learn_rate)
	
	# model parameters
	test_parameters = Flux.params(test_model)
end;

# ╔═╡ 8a66e1fe-93df-11eb-2fdb-4936f115a745
md"__*All that is left is to train !*__"

# ╔═╡ 8a898c90-93df-11eb-164d-59e3f836849c
begin
	test_epochs = 10
	@epochs test_epochs Flux.train!(
		test_loss,
		test_parameters,
		test_train_data,
		test_optimiser
	)
	
	trained_accuracy = test_accuracy(test_model(x_valid), y_valid)
end;

# ╔═╡ 8a8b895a-93df-11eb-10c7-fd38146a1517
md"""
`test_model` performs well after being trained for $(test_epochs) epochs, with a final accuracy score of:

$(trained_accuracy)
"""

# ╔═╡ 8ac3e5e8-93df-11eb-20de-c57f88e51216
# Flux.train! gets stuck after Epoch 1
# This is most likely an issue with the callback
# since this issue was not observed in the previous training attempt
begin
	loss_vector = Vector{Float64}()
	callback() = push!(loss_vector, test_loss(x_train, y_train))
	
	# @epochs test_epochs Flux.train!(
	# 	test_loss,
	# 	test_parameters,
	# 	test_train_data,
	# 	test_optimiser,
	# 	cb=callback
	# )
end;

# ╔═╡ Cell order:
# ╟─87cac48a-93df-11eb-031d-8b4cebe1282e
# ╠═87e2af94-93df-11eb-3e9e-4bcb05b5c6dc
# ╟─87eff10c-93df-11eb-224e-19ac8c577709
# ╠═880b6934-93df-11eb-372e-a79e1acbcfa0
# ╟─882522cc-93df-11eb-072a-b5e085c0a06d
# ╠═883654c8-93df-11eb-19c0-bb9a4d9ea1e0
# ╟─88379928-93df-11eb-2ea9-4deb244af06b
# ╠═88469704-93df-11eb-2329-2de5ece4d939
# ╟─8853c08a-93df-11eb-3a6c-ebf587191d94
# ╠═8866cc48-93df-11eb-095e-fb50745e050b
# ╟─8868630a-93df-11eb-2389-af9749856a19
# ╠═88a7917e-93df-11eb-1206-f31e48b1314b
# ╟─88dc844c-93df-11eb-0456-cb4a6bf00391
# ╠═8946f264-93df-11eb-307b-f51da5bedae6
# ╠═89615226-93df-11eb-3f2b-fb0999cc5a56
# ╠═89910b88-93df-11eb-3edb-3f6e11ddb643
# ╠═89cbbe40-93df-11eb-283a-69cef1cda710
# ╠═8a4b8dfa-93df-11eb-0ea9-8985a3f3049c
# ╠═8a66e1fe-93df-11eb-2fdb-4936f115a745
# ╠═8a898c90-93df-11eb-164d-59e3f836849c
# ╠═8a8b895a-93df-11eb-10c7-fd38146a1517
# ╠═8ac3e5e8-93df-11eb-20de-c57f88e51216
