JobQueue = require "./job-queue"
vows = require "vows"
assert = require "assert"

vows.describe "job-queue"
	.addBatch
		"Test 1":
			topic: new JobQueue
			"No consumers": (jobQueue) ->
				assert.deepEqual jobQueue.consumers, []
			"No pending jobs": (jobQueue) ->
				assert.equal jobQueue.pendingJobs, 0
		"Test 2":
			topic: ->
				makeConsumer = (consumerId) ->
					(job) ->
						job.process consumerId
				jobQueue = new JobQueue [1..5].map(makeConsumer), 5, 1
				jobQueue.addConsumers [6..10].map(makeConsumer), 8, 2
				for jobId in [1..500] then do (jobId) ->
					jobQueue.enqueue
						id: jobId
						process: (consumerId) ->
				jobQueue
			"Initially":
				topic: (jobQueue) -> jobQueue
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"500 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 500
			"After 100 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 100
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"435 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 435
			"After 1.1 s":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1100
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"After 1.6 s":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1600
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"After 2.1 s":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 2100
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"345 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 345
			"After 5.1 s":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 5100
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"230 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 230
			"After 10.1 s":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 10100
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"0 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 0
	.export module

###
process.on "uncaughtException", (err) ->
	console.error "Caught exception: " + err
	process.removeAllListeners "uncaughtException"
###