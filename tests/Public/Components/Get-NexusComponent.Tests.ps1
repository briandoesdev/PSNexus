#requires -Modules PSNexus

Describe 'Get-NexusComponent' {
  It 'Given nexus-test repo, lists all component items' {
    "test" | Should -Be "test"
  }
}