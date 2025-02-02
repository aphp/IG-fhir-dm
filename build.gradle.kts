import com.github.gradle.node.npm.task.NpmTask
import com.github.gradle.node.npm.task.NpxTask
import java.nio.file.Files

plugins {
  id("java")
  id("com.github.node-gradle.node") version "7.0.2"
  id("de.undercouch.download") version "5.6.0"
}

group = "fr.aphp"
version = File(projectDir.absolutePath,"sushi-config.yaml")
  .readLines()
  .find {
    it.contains("version")
  }?.substringAfter("version: ")?: "unknown"

node {
  download.set(true)
  version.set("${properties["nodeVersion"]}")
}

defaultTasks(
  "cleanIG",
  "buildIG"
)

fun installRemoteJar(name: String, path: String, url: String): TaskProvider<Task> {
  return tasks.register<Task>(name + "Install") {
    group = "build setup"
    doLast{
      Files.createDirectories(file("input-cache").toPath())

      download.run {
        src(url)
        dest(path)
        overwrite(false)
      }
    }
  }
}

val igPackageManagerPath = "bin/manager.jar"
/*val igPackageManagerInstall = installRemoteJar(
    "igPackageManager",
    igPackageManagerPath,
    "https://gitlab.data.aphp.fr/api/v4/projects/2285/packages/maven/fr/aphp/ig-package-manager/${properties["managerVersion"]}/ig-package-manager-${properties["managerVersion"]}.jar",
)*/

val igPackageManager = tasks.register<JavaExec>("igPackageManager") {
  group = "build"

  classpath(igPackageManagerPath)
  args = listOf(
    "-ig",
    projectDir.absolutePath
  )
  /*dependsOn(
          igPackageManagerInstall
  )*/
}

val usageSynchroPath = "bin/usage-synchro.jar"
/*val usageSynchroInstall = installRemoteJar(
    "usageSynchro",
    usageSynchroPath,
    "https://gitlab.data.aphp.fr/api/v4/projects/2098/packages/maven/fr/aphp/usage-synchro/${properties["usageSynchroVersion"]}/usage-synchro-${properties["usageSynchroVersion"]}.jar",
    )*/

val ddlBuild = tasks.register<JavaExec>("ddlBuild") {
  group = "build"

  jvmArgs("-Dfile.encoding=UTF-8")
  classpath(usageSynchroPath)
  args = listOf(
    "-m",
    "ddl",
    "-ig",
    projectDir.absolutePath
  )
  /*dependsOn(
      usageSynchroInstall
  )*/
}

val usageBusinessBuild = tasks.register<JavaExec>("usageBusinessBuild") {
  group = "build"

  jvmArgs("-Dfile.encoding=UTF-8")
  classpath(usageSynchroPath)
  args = listOf(
    "-m",
    "business",
    "-ig",
    projectDir.absolutePath
  )
  /*dependsOn(
      usageSynchroInstall
  )*/
}

val sushiInstall = tasks.register<NpmTask>("sushiInstall") {
  args.set(
    listOf(
      "install",
      "fsh-sushi@${properties["sushiVersion"]}"
    )
  )
  dependsOn(
    tasks.nodeSetup,
    tasks.npmSetup,
    tasks.npmInstall
  )
}

val sushiBuild = tasks.register<NpxTask>("sushiBuild") {
  command.set("sushi")
  args.set(
    listOf(
      "build",
      projectDir.absolutePath
    )
  )
  dependsOn(
    igPackageManager,
    sushiInstall
  )
}

val igPublisherPath = "input-cache/publisher.jar"
val igPublisherInstall = installRemoteJar(
  "igPublisher",
  igPublisherPath,
  "https://github.com/HL7/fhir-ig-publisher/releases/download/${properties["publisherVersion"]}/publisher.jar",
)

val igPublisherBuild = tasks.register<JavaExec>("igPublisherBuild") {
  group = "build"

  jvmArgs("-Dfile.encoding=UTF-8")
  classpath(igPublisherPath)
  args = listOf(
    "-no-sushi",
    "-tx ${properties["tx"]}",
    "-ig",
    projectDir.absolutePath
  )
  dependsOn(
    igPublisherInstall
  )
}

val buildIG = tasks.register<GradleBuild>("buildIG") {
  group = "build"

  tasks = listOf(
    "ddlBuild",
    "sushiBuild",
    "usageBusinessBuild",
    "igPublisherBuild"
  )
}

val reBuildIG = tasks.register<GradleBuild>("reBuildIG") {
  group = "build"

  tasks = listOf(
    "cleanIG",
    "buildIG"
  )
}

val cleanIG = tasks.register<Delete>("cleanIG") {
  group = "build"

  delete(
    "fsh-generated",
    "output",
    "temp",
    "template",
    "input-cache",
    ".gradle/nodejs",
    "node_modules",
    "package.json",
    "package-lock.json"
  )
}