import Foundation
import XCTest
@testable import Sh

final class ReturningAllOutputTests: XCTestCase {
  
  func testSimple() throws {
    let process = Process(cmd: #"echo "simple""#)
    let allOutput = try process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut, "simple\n".data(using: .utf8)!)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  func testSimpleAsync() async throws {
    let process = Process(cmd: #"echo simple"#)
    let allOutput = try await process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut.asTrimmedString(), "simple")
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  func testLoremIpsumData() throws {
    let cmd = #"echo "$LOREM_IPSUM""#
    let environment = ["LOREM_IPSUM": loremIpsum]
    let output = try sh(cmd, environment: environment)
    XCTAssertEqual(output, loremIpsum)
  }
  
  func testLoremIpsum() throws {
    let process = Process(cmd: #"echo "$LOREM_IPSUM""#, environment: ["LOREM_IPSUM": loremIpsum])
    let allOutput = try process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut.asTrimmedString(), loremIpsum)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  func testLoremIpsumAsync() async throws {
    let process = Process(cmd: #"echo "$LOREM_IPSUM""#, environment: ["LOREM_IPSUM": loremIpsum])
    let allOutput = try await process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut.asTrimmedString()?.count, loremIpsum.count)
    XCTAssertEqual(allOutput.stdOut.asTrimmedString(), loremIpsum)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  private let loremIpsum = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse id pretium ex. Aliquam rhoncus libero dolor, ut egestas mauris auctor ut. Curabitur accumsan pharetra sagittis. Aliquam neque elit, venenatis ac luctus id, bibendum vel arcu. Nulla sollicitudin bibendum tincidunt. Vestibulum lectus sapien, facilisis a bibendum viverra, ullamcorper scelerisque leo. Proin mollis commodo orci at accumsan. Aenean nisl ex, iaculis tincidunt eros quis, consequat auctor nisl. Integer nec felis egestas erat posuere aliquam. Praesent commodo nibh rutrum, eleifend sem vitae, molestie est. Aenean eleifend ipsum vel tellus fermentum mattis.

Phasellus mollis ut enim id pellentesque. Proin congue est feugiat odio vestibulum volutpat. In varius aliquam sapien eu iaculis. Phasellus vitae mauris sit amet massa euismod dictum vel in metus. Morbi ut orci et libero cursus consequat vitae vel eros. Donec accumsan dolor sit amet tincidunt porta. Sed bibendum risus at justo euismod, ut rhoncus urna molestie. Praesent at congue odio, vitae consequat leo. Etiam vel cursus leo, ac fringilla lacus. Duis ac tempus ante. Donec vel elementum mi, ut lobortis enim.

Quisque quis lobortis erat, sit amet pharetra ipsum. Sed convallis enim dui, nec placerat dui gravida id. Integer facilisis erat vel risus eleifend accumsan. Praesent sit amet nibh nulla. Nulla facilisi. Suspendisse ultricies, lectus quis tristique pulvinar, leo nulla convallis libero, eget rutrum lorem urna vitae turpis. In scelerisque ipsum et aliquam eleifend. Nullam egestas tincidunt dictum. In magna nisi, laoreet nec dui in, aliquet porttitor metus. Aenean neque ligula, vulputate eu dictum porttitor, consequat sed risus. Sed pellentesque egestas euismod. In tristique mollis sollicitudin. Suspendisse fermentum justo nec ipsum rutrum bibendum.

Fusce convallis elit in accumsan efficitur. Etiam commodo dapibus elit rhoncus rutrum. Sed pellentesque dolor sed velit viverra scelerisque. Aliquam erat volutpat. Aliquam malesuada purus nulla, at efficitur sem blandit ac. Maecenas congue, lacus eget vestibulum vestibulum, sapien quam lacinia arcu, et vestibulum diam sapien et ipsum. Sed semper metus arcu.

Nulla auctor semper convallis. Etiam at justo ac lacus varius suscipit. Vestibulum fermentum dolor quis nunc gravida gravida. Nulla placerat tincidunt quam ac hendrerit. Donec nec ligula non sem pulvinar congue nec non felis. Nunc aliquam elit at enim bibendum, nec laoreet quam congue. Nam vel ipsum purus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

Donec in risus augue. Duis pellentesque semper hendrerit. Sed finibus ut nunc at rutrum. Suspendisse potenti. Proin a ligula sed orci bibendum consectetur. Nullam convallis justo nec sodales vulputate. Aliquam dui tortor, pellentesque eget elementum et, commodo at dui. Nunc tempus purus quis interdum volutpat. Curabitur egestas a ligula ac pretium. Donec finibus rutrum arcu. In consequat lorem a maximus aliquet. Vestibulum elementum purus a est condimentum, sit amet interdum ex lobortis. Morbi dignissim dapibus dui non sollicitudin. In dapibus sodales tortor, vel volutpat justo fringilla tempus.

Nunc efficitur quam eu mi dignissim interdum nec in velit. In hac habitasse platea dictumst. Integer at risus urna. Donec arcu turpis, bibendum a tempor ac, auctor nec nunc. Vestibulum a tempor nunc, sit amet vulputate ligula. Donec ac consequat nibh, quis dignissim nunc. Mauris metus purus, consectetur vitae felis pretium, condimentum consequat tellus. Ut sed placerat libero. Aliquam erat volutpat.

Fusce ultrices volutpat rutrum. Quisque sodales lorem ac enim semper, non suscipit arcu vestibulum. Nulla nec viverra felis. Nam et mauris nec libero condimentum dapibus. Sed vitae tincidunt nisl, non consequat ipsum. Praesent ante urna, dignissim sit amet tellus eget, scelerisque interdum augue. Duis imperdiet eros eu aliquet congue. Aliquam ut eros non urna viverra lobortis. Nam vitae vestibulum enim. Etiam gravida mi non laoreet ultrices. Etiam ut velit in velit finibus posuere vitae iaculis lorem. Maecenas mollis, nunc vel imperdiet pharetra, neque orci pulvinar elit, nec vehicula ipsum purus non est.

Proin et rutrum erat. Morbi euismod est non sodales dignissim. Phasellus ac dui congue tellus sodales feugiat. Aliquam lacinia, neque sit amet venenatis consequat, magna ex vestibulum dui, at ultricies dui arcu quis metus. Vestibulum porttitor sodales neque, quis molestie ex auctor et. Etiam fringilla tincidunt gravida. Phasellus a dolor neque. Fusce et facilisis sem. Nullam at cursus turpis. Pellentesque finibus arcu a ligula aliquet, id semper nisi molestie. Donec a mauris eget neque dictum dignissim. Etiam maximus iaculis nunc, non dapibus lacus tristique maximus. Praesent porttitor congue gravida. Suspendisse vehicula eros pretium, fermentum neque nec, tempor sapien. Nullam auctor ac lacus id lacinia.

In nibh turpis, ultricies nec dapibus venenatis, iaculis quis mauris. Sed ut finibus leo. Proin vel velit erat. Fusce vel vestibulum arcu. Interdum et malesuada fames ac ante ipsum primis in faucibus. Praesent porttitor consequat porttitor. Maecenas ac tellus volutpat, rutrum sapien in, accumsan tortor. Suspendisse iaculis auctor ante, vitae ornare mauris luctus eu. In nec tortor vitae nulla porta suscipit. In vel nisl aliquet, lobortis eros et, maximus massa. Nunc id malesuada diam.

Praesent fringilla tempor semper. Aliquam erat volutpat. Pellentesque efficitur volutpat quam ac blandit. Duis hendrerit iaculis massa, eget ornare erat cursus non. Praesent aliquet, augue a tincidunt luctus, ligula nulla posuere ante, eu blandit ante eros at magna. Maecenas egestas consequat convallis. Nulla facilisi. Phasellus et sem ac sapien interdum placerat non eu sem. Morbi auctor in metus a feugiat. Interdum et malesuada fames ac ante ipsum primis in faucibus. Duis dignissim metus vitae elementum placerat. In vitae tempor risus, eget euismod massa. Quisque eget dui suscipit, posuere velit eget, eleifend enim.

Curabitur mattis eros ipsum, at posuere justo aliquam sollicitudin. Donec dictum pellentesque lorem, in tempus ipsum scelerisque consequat. Sed vitae lorem ornare, scelerisque urna vel, venenatis neque. Phasellus ultricies eu arcu sed tempor. Phasellus gravida mauris sed aliquam pellentesque. Curabitur viverra quam ac lectus ultricies gravida. Praesent eget volutpat ligula.

Aliquam erat volutpat. Sed commodo ligula non nunc pulvinar, vel pretium velit placerat. Sed pulvinar urna lacinia ipsum fermentum, nec tincidunt purus blandit. Nunc sodales dolor quis congue tristique. Nam id diam elementum, venenatis lorem vel, rhoncus enim. Ut ut dapibus neque. Suspendisse euismod arcu vitae mollis eleifend.

Pellentesque scelerisque, purus vitae suscipit consectetur, diam lacus ultricies ex, vehicula lobortis ligula ipsum ut magna. Nulla blandit egestas massa non ultricies. In purus lorem, volutpat ac efficitur ac, vehicula quis felis. Suspendisse potenti. Praesent suscipit, ipsum vel varius vulputate, felis sem mattis ex, vitae aliquet massa felis ut nibh. Integer id arcu arcu. Ut pulvinar ipsum in ipsum tempor, sit amet iaculis risus commodo. Suspendisse euismod mi a elementum tincidunt. Quisque id dapibus sem. Nam hendrerit arcu ut auctor cursus. Mauris condimentum mi non malesuada viverra. Vivamus dictum sed nulla dapibus vehicula. Ut facilisis augue nunc, nec commodo ante ullamcorper id. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed pharetra turpis nec urna suscipit volutpat.
""".trimmingCharacters(in: .whitespacesAndNewlines)
}
