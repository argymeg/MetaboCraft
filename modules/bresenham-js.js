//Modified version of Jonathan Faulch's bresenham-js (MIT-licensed).
//Intended for use as a scriptcraft module only!

(function(root, propertyName)
{
	root[propertyName] = function(pos1, pos2)
	{
		var delta = pos2.map(function(value, index) { return value - pos1[index]; });
		var increment = delta.map(function(value) {
			if(value > 0){
				return 1;
			}
			else if(value < 0){
				return -1;
			}
			else{
				return 0;
			}
		});
		var absDelta = delta.map(function(value) { return Math.abs(value); });
		var absDelta2 = absDelta.map(function(value) { return 2 * value; });
		var maxIndex = absDelta.reduce(function(accumulator, value, index) { return value > absDelta[accumulator] ? index : accumulator; }, 0);
		var error = absDelta2.map(function(value) { return value - absDelta[maxIndex]; });

		var result = [];
		var current = pos1.map(function(value) { return value; });
		for (var i = 0; i < absDelta[maxIndex]; i++)
		{
			result.push(current.map(function(value) { return value; }));
			error.forEach(function(errorValue, index)
			{
				if (error[index] > 0)
				{
					current[index] += increment[index];
					error[index] -= absDelta2[maxIndex];
				}
				error[index] += absDelta2[index];
			});
		}
		result.push(current.map(function(value) { return value; }));
		return result;
	};
}).apply(this, typeof module === 'undefined' ? [this, 'bresenham'] : [module, 'exports']);
