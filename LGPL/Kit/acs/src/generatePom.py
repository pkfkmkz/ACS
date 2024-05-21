#!/usr/bin/env python

################################################################################################
import os
import re
import argparse
################################################################################################

# constants
pom_template ='''<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <name>{name}</name>
    <groupId>{groupId}</groupId>
    <artifactId>{artifactId}</artifactId>
    <version>${{revision}}${{sha1}}${{changelist}}</version>
    <packaging>jar</packaging>

    <dependencies>
        {dependencies}
    </dependencies>

    <properties>
        <revision>{version}</revision>
        <changelist></changelist>
        <sha1/>
    </properties>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
                <executions>
                    <execution>
                        <id>default-compile</id>
                        <phase>none</phase>
                    </execution>
                    <execution>
                        <id>default-testCompile</id>
                        <phase>none</phase>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.10.1</version>
                <executions>
                    <execution>
                        <id>default-test</id>
                        <phase>none</phase>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>3.2.2</version>
                <executions>
                    <execution>
                        <id>default-jar</id>
                        <phase>none</phase>
                    </execution>
                </executions>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-install-plugin</artifactId>
                <version>2.5.2</version>
                <configuration>
                    <file>{jarfile}</file>
                    <groupId>${{project.groupId}}</groupId>
                    <artifactId>${{project.artifactId}}</artifactId>
                    <version>${{project.version}}</version>
                    <packaging>${{project.packaging}}</packaging>
                    <pomFile>${{project.artifactId}}.pom.xml</pomFile>
                </configuration>
                <executions>
                    <execution>
                        <id>default-install</id>
                        <phase>none</phase>
                    </execution>
                    <execution>
                        <id>install-file</id>
                        <phase>install</phase>
                        <goals>
                            <goal>install-file</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>2.8.2</version>
                <configuration>
                    <skip>${{skipDeploy}}</skip>
                    <file>{jarfile}</file>
                    <groupId>${{project.groupId}}</groupId>
                    <artifactId>${{project.artifactId}}</artifactId>
                    <version>${{project.version}}</version>
                    <packaging>${{project.packaging}}</packaging>
                    <pomFile>${{project.artifactId}}.pom.xml</pomFile>
                    <repositoryId>${{project.distributionManagement.repository.id}}</repositoryId>
                    <url>${{project.distributionManagement.repository.url}}</url>
                </configuration>
                <executions>
                    <execution>
                        <id>default-deploy</id>
                        <phase>none</phase>
                    </execution>
                    <execution>
                        <id>deploy-file</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>deploy-file</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>flatten-maven-plugin</artifactId>
                <version>1.2.7</version>
                <configuration>
                    <updatePomFile>true</updatePomFile>
                    <flattenMode>resolveCiFriendliesOnly</flattenMode>
                    <flattenedPomFilename>${{project.artifactId}}.pom.xml</flattenedPomFilename>
                </configuration>
                <executions>
                    <execution>
                        <id>flatten</id>
                        <phase>process-resources</phase>
                        <goals>
                            <goal>flatten</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>flatten.clean</id>
                        <phase>clean</phase>
                        <goals>
                            <goal>clean</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

    <profiles>
        <profile>
            <id>no-deploy</id>
            <properties>
                <skipDeploy>true</skipDeploy>
                <distributionManagementId.release>localhost</distributionManagementId.release>
                <distributionManagementURL.release>file:///tmp/</distributionManagementURL.release>
                <distributionManagementId.snapshot>localhost</distributionManagementId.snapshot>
                <distributionManagementURL.snapshot>file:///tmp/</distributionManagementURL.snapshot>
            </properties>
            <activation>
                <property>
                    <name>!env.ACS_MAVEN_PROF</name>
                </property>
            </activation>
        </profile>
        <profile>
            <id>acs-profile</id>
            <distributionManagement>
                <repository>
                    <id>${{distributionManagementId.release}}</id>
                    <name>Release repository</name>
                    <url>${{distributionManagementURL.release}}</url>
                </repository>
                <snapshotRepository>
                    <id>${{distributionManagementId.snapshot}}</id>
                    <name>Snapshot repository</name>
                    <url>${{distributionManagementURL.snapshot}}</url>
                </snapshotRepository>
            </distributionManagement>
            <activation>
                <activeByDefault>true</activeByDefault>
                <property>
                    <name>!env.ACS_MAVEN_PROF</name>
                </property>
            </activation>
        </profile>
    </profiles>
</project>'''

dep_template = '''<dependency>
            <groupId>{groupId}</groupId>
            <artifactId>{artifactId}</artifactId>
            <version>${{project.version}}</version>
        </dependency>'''

ext_dep_template = '''<dependency>
            <groupId>{groupId}</groupId>
            <artifactId>{artifactId}</artifactId>
            <version>{version}</version>
        </dependency>'''

class SafeDict(dict):
    def __missing__(self, key):
        return '{' + key + '}'

def get_dependency(groupId, jar, version=None, acsversion=None):
    exp = re.compile(r'^(.*)-((\d+)(\.\d+)*)$')
    res = exp.match(jar)
    if not res is None:
        jar = res.group(1)
        version = res.group(2)
    if version == acsversion:
        return dep_template.format(groupId=groupId, artifactId=jar, version=version)
    return ext_dep_template.format(groupId=groupId, artifactId=jar, version=version)

if  __name__=="__main__":
    parser = argparse.ArgumentParser("generatePom")
    parser.add_argument("--pom", "-p", help="Template POM file. Default: Internal definition", type=str, required=False)
    parser.add_argument("--out", "-o", help="Destination directory path. Default: Working directory", type=str, required=False)
    parser.add_argument("--filename", "-f", help="File name. Default: pom.xml", type=str, required=False)
    parser.add_argument("--deps", "-d", help="List of dependencies to consider", type=str, required=False)
    parser.add_argument("--group", "-g", help="Group id of the artifact to be produced", type=str, required=True)
    parser.add_argument("--artifact", "-a", help="Artifact id of the artifact to be produced", type=str, required=True)
    parser.add_argument("--jarfile", "-j", help="Path to jarfile to be used for install and deploy targets", type=str, required=False)
    parser.add_argument("--version", "-v", help="Target artifact version", type=str, required=True)
    #parser.add_argument("--py", "-p", help="Use internal Python XSLT transformation filei", action="store_true", required=False)
    args = parser.parse_args()


    path = None if args.out is None else args.out
    filename = 'pom.xml' if args.filename is None else args.filename
    filepath = filename if path is None else path + '/' + filename
    pom = pom_template if args.pom is None else args.pom
    deps = [] if args.deps is None else args.deps.split(',')
    jarf = os.path.join(os.path.dirname(filepath), args.artifact) + '.jar' if args.jarfile is None else args.jarfile

    dependencies = []
    for jar in deps:
        group = 'alma' if args.group is None else args.group
        version = args.version
        artifact = jar
        if jar.count(':') > 0:
            group = jar.split(':')[0]
            artifact = jar.split(':')[1]
        if jar.count(':') > 1:
            version = jar.split(':')[2]
        dep = get_dependency(group, artifact, version, args.version)
        if not dep is None:
            dependencies.append(dep)
        else:
            print('Failed to find dependency for %s' % jar)

    f = open(filepath, 'w')
    f.write(pom.format_map(SafeDict(name=args.artifact, artifactId=args.artifact, groupId=args.group, version=args.version, dependencies='\n        '.join(dependencies), jarfile=jarf)))
    f.close()
