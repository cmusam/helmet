# [Final Report (click here)](http://tinyurl.com/yans-418)

---

# Checkpoint (4/19)

### Work I have completed so far
Having no previous experience in Swift, I familiarized myself with Swift and Objective C to prepare for this project. As a first step, I replicated the sequential versions assignment one programs in Swift. I plan to use these single core single thread performance as the benchmark for later improvements.

### Work schedule
The original schedule was to complete the basic parallel primitives (map, reduce, scan, filter) by 4/15. Since learning Swift and setting up the appropriate environments took longer than expected, I have yet completed implementing them. 

Yes, I still believe I will be able to produce all your deliverables. An updated and more refined schedule is as below. I plan to have intermediate updates to this webpage at each of the following dates.
- 4/23 (Friday) fully set up Metal and test GPU computation
- 4/26 (Tuesday) map, reduce
- 4/30 (Friday) scan, filter
- 5/3 (Tuesday) machine learning application start
- 5/6 (Friday) machine learning application done

### Presentation at parallelism competition
Graphs showing (hopefully) a significant speedup using Swift on a common machine learning routine. Explain the motivation of the project, and possible applications of the Blade library.

### Preliminary results
I have set benchmarks by running assignment one programs using single core single thread environments. More results to follow once the primitives are implemented. 

### Concerns and unknowns
Finding an appropriate dataset to apply machine learning algorithms using Blade. The dataset should be of an appropriate size. Also, I should ideally record a benchmark performance using a sequential algorithm.

---

# Proposal (4/1)

### Summary
I plan to implement a Swift 2.0 Library that allows efficient GPU parallel computations on Mac OS X using Metal. Compared to iOS devices, Macs have more powerful GPUs with larger on-device memories, creating greater potential for parallel computation.

### Background
In December 2015, Swift was open sourced and is possibly on its way to become a mainstream programming language. At WWDC 2015, Apple announced support for Metal on OS X, unleashing more efficient computing possibilities for Mac OS applications.

Although originally designed for iOS applications to realize fast real time graphic processing, one important feature of Metal is its integrated support for both graphics and compute operations. Therefore, fields requiring large scale computation such as deep learning can also benefit greatly from this library. 

### The Challenge
Both the Metal API and Swift 2.0 are relatively new. Support and documentation may therefore be limited. I expect more challenge to arise as I proceed with the project.

### Resources
- https://developer.apple.com/metal/
- https://developer.apple.com/swift/resources/parall

### Goals and Deliverables
If successful, I plan to deliver a set of common parallel primitives that can be used directly in Swift 2.0. To achieve speedup on parallelizable computations,   we expect users to have no knowledge of Metal or the GPU.

### Platform Choice
- Mac OS X El Capitan
- Swift 2.0

### Schedule
- 4/1 Proposal
- 4/8 Conduct research on and experimenting with Metal on Mac OS X.
- 4/15 Implement fundamental GPU algorithms such as scan, sort, reduce, map.
- 4/28 Evaluate and possibly improve the performance of existing code.
- 5/9 Deadline
