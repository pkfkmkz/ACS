def nestedName = "Integration"
def oldRelease = "2021APR"
def newRelease = "2021JUN"

def nestedView = Jenkins.instance.getView(nestedName)
def oldView = nestedView.getView(oldRelease)

//Check if view exist and delete or bail out!
def newView = nestedView.getView(newRelease)
if (newView != null) {
  println(newView.toString() + " already exists!")
  remove = false
  if (remove) {
    items = newView.getItems()
    items.each {
      println(it.name)
      it.delete()
    }
    nestedView.deleteView(newView)
  }
  return
}

//Create new ListView and add it to nestedView
nestedView.addView(new ListView(newRelease, nestedView))
newView = nestedView.getView(newRelease)

//Iterate jobs in view
for(item in oldView.getItems()) {
  //Copy job with new name
  name = item.getName().replace(oldRelease, newRelease)
  def job = Hudson.instance.copy(item, name)
  
  //Change the branch in the SCM (only if Git for now)
  job.getSCMs().each {
    if (it instanceof hudson.plugins.git.GitSCM) {
      it.getBranches().each {
        it.name = it.name.replace(oldRelease, newRelease)
      }
    }
  }
  
  //Modify the job from which we're getting the artifacts
  //We're removing and re-adding all builders just to maintain the same order
  def builders = job.getBuildersList()
  builders.each {
    builders.remove(it)
    if (it instanceof hudson.plugins.copyartifact.CopyArtifact) {
      builders.add(new hudson.plugins.copyartifact.CopyArtifact(it.projectName.replace(oldRelease, newRelease), it.parameters, it.selector, it.filter, it.target, it.flatten, it.optional, it.fingerprintArtifacts))
    } else {
      builders.add(it)
    }
  }
  
  //Modify the downstream jobs that are called when finished
  //We're removing and re-adding all publishers just to maintain the same order
  def pubs = job.getPublishersList()
  pubs.each {
    pubs.remove(it)
    if (it instanceof hudson.tasks.BuildTrigger) {
      pubs.add(new hudson.tasks.BuildTrigger(it.childProjectsValue.replaceAll(oldRelease, newRelease), it.threshold))
    } else {
      pubs.add(it)
    }
  }
  
  //Modify the StringParameterDefinitions which have the oldRelease as default value
  def params = job.getProperty('hudson.model.ParametersDefinitionProperty')
  if (params != null) {
    params.parameterDefinitions.each {
      if (it instanceof hudson.model.StringParameterDefinition) {
        it.defaultValue = it.defaultValue.replace(oldRelease, newRelease)
      }
    }
  }
  
  //Save changes to the job
  job.save()
  
  //Add job to the new view
  newView.doAddJobToView(name)
}
