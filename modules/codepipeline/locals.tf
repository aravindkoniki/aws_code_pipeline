locals {
  # Convert map to list of objects
  stages_list_unsorted = flatten([
    for key, stage in var.stages : [{
      name             = stage.name
      run_order        = stage.run_order
      category         = stage.category
      input_artifacts  = stage.input_artifacts
      output_artifacts = stage.output_artifacts
    }]
  ])


  stages_sort_by_index = distinct(sort(local.stages_list_unsorted[*].run_order))

  stages_sorted = flatten(
    [
      for value in local.stages_sort_by_index :
      [for elem in var.stages :
        elem if tonumber(elem.run_order) == tonumber(value)
      ]
    ]
  )

}
