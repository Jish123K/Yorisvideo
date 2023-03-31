import Quick

import Nimble

import YiVideoEditor

class YiVideoEditorSpec: QuickSpec {

    override func spec() {

        describe("YiVideoEditor") {

            var editor: YiVideoEditor!

            

            beforeEach {

                editor = YiVideoEditor()

            }

            

            afterEach {

                editor = nil

            }

            

            it("should pass the example test") {

                expect(true).to(beTrue())

            }

            

            it("should complete the performance test in under 1 second") {

                self.measure {

                    // Put the code you want to measure the time of here.

                }

                expect(self).to(completeWithTimeInterval(1))

            }

        }

    }

}

