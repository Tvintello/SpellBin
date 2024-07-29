extends Node


func array_unique(array: Variant) -> Array:
	var unique: Array = []

	for item in array:
		if not unique.has(item):
			unique.append(item)

	return unique


func zero_matrix(nX: int, nY: int):
	var matrix = []
	for x in range(nX):
		matrix.append([])
		for y in range(nY):
			matrix[x].append(0)
	return matrix
	
	
func zero_array(size: int):
	var matrix = []
	for x in range(size):
		matrix.append(0)
	return matrix
	

func multiply_matrices(a: Array, b: Array):
	var matrix = zero_matrix(a.size(), b[0].size())
  
	for i in range(a.size()):
		for j in range(b[0].size()):
			for k in range(a[0].size()):
				matrix[i][j] = matrix[i][j] + a[i][k] * b[k][j]
	return matrix
	
	
func multiply_matrix_col_vector4(a: Array, b: Vector4):
	var vector = Vector4.ZERO
	
	for row in range(a.size()):
		for col in range(a[row].size()):
			vector[row] += a[row][col] * b[col]
  
	return vector
	
	
