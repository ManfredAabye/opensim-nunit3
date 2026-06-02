using NUnit.Framework;

namespace OpenSim.Tests
{
    [TestFixture]
    public class NUnitCompatibilitySmokeTests
    {
        [Test]
        public void NUnit3RunnerIsWorking()
        {
            Assert.That(true, Is.True);
        }
    }
}
