require "spec_helper"

describe "ShiftGenerator" do
  include ShiftGenerator

  context "Fixed number" do
    it "MAX_RETRY_COUNT_FOR_MAIN is 1500" do
      expect(ShiftGenerator::MAX_RETRY_COUNT_FOR_MAIN).to eq 1500
    end

    it "MAX_RETRY_COUNT_FOR_SELECT is 1000" do
      expect(ShiftGenerator::MAX_RETRY_COUNT_FOR_SELECT).to eq 1000
    end
  end

  context "Assignment class" do
    before do
      args1 = ""
      args2 = ""
      args3 = ""
      @assign = ShiftGenerator::Assignment.new(args1, args2, args3)
    end

    it "Assignment has assignment_name" do
      expect(@assign.assignment_name).to eq ""
    end

    it "Assignment has member_assignments" do
      expect(@assign.member_assignments).to eq ""
    end

    it "Assignment has time_assignments" do
      expect(@assign.time_assignments).to eq ""
    end
  end

  context "select_members" do
    context "when there are enough members " do
      it "returns any one of them" do
        selected_members = send(:select_members, ["a", "b", "c"], 1, [""])
        expect(selected_members.size).to eq 1
      end

      it "returns 'a'" do
        selected_members = send(:select_members, ["a", "b", "c"], 1, ["b", "c"])
        expect(selected_members).to include "a"
      end

      it "returns all 'a', 'b', 'c'" do
        selected_members = send(:select_members, ["a", "b", "c"], 4, [""])
        expect(selected_members.size).to eq 3
      end
    end

    context "when there are not enough members " do
      it "throws RuntimeError exception" do
        expect do
          selected_members = send(:select_members, ["a", "b", "c"], 1, ["a", "b", "c"])
        end.to raise_error(RuntimeError, "MAX RETRY COUNT FOR SELECT EXCEEDED")
      end
    end
  end

  context "generate_shifts" do
    context "successfully generate" do
      shifts = []
      before do
        members = [
                    'Tre McLaughlin', 'Leora Murazik', 'Franz Strosin',
                    'Catalina Lowe', 'Bobbie Nicolas', 'Candido Witting',
                    'Elias Auer', 'Briana Weimann', 'Rollin Dickens',
                    'Jordi Hills', 'Emery Marks', 'Zack Turcotte',
                    'Estrella Konopelski', 'Loren Sawayn', 'Alexandrine Gutkowski',
                    'Krystel McKenzie', 'Destany Barrows', 'Dario DAmore',
                    'Vidal Schoen', 'Pearlie Quitzon', 'Alverta Klocko',
                    'Haley Wunsch'
                  ]
        count    = 1

        assignment_name     = "Assignment 1"
        member_assignments  = [3, 3, 4]
        time_assignments    = [3, 3, 3]
        asgn1 = ShiftGenerator::Assignment.new(assignment_name, member_assignments, time_assignments)

        assignment_name     = "Assignment 2"
        member_assignments  = [1, 1, 1]
        time_assignments    = [3, 3, 3]
        asgn2 = ShiftGenerator::Assignment.new(assignment_name, member_assignments, time_assignments)
        
        assignment_name     = "Assignment 3"
        member_assignments  = [1, 1]
        time_assignments    = [4, 5]
        asgn3 = ShiftGenerator::Assignment.new(assignment_name, member_assignments, time_assignments)

        shifts = generate_shifts(members, count, [asgn1, asgn2, asgn3])
        # puts JSON.pretty_generate(JSON.parse(shifts.to_json))
      end
      
      it "shifts have 1 shift" do
        expect(shifts.size).to eq 1
      end

      it "shifts have 3 assignments" do
        expect(shifts[0].size).to eq 3
      end

      it "Assignment 1 has 3 groups" do
        expect(shifts[0][0].size).to eq 3
      end

      it "Assignment 2 has 3 groups" do
        expect(shifts[0][1].size).to eq 3
      end

      it "Assignment 3 has 2 groups" do
        expect(shifts[0][2].size).to eq 2
      end
    end

    context "unsuccessfully generate" do
      members             = ['Tre McLaughlin', 'Leora Murazik', 'Franz Strosin']
      count               = 1
      assignment_name     = "Assignment 1"
      member_assignments  = [3, 1]
      time_assignments    = [4, 5]
      asgn1 = ShiftGenerator::Assignment.new(assignment_name, member_assignments, time_assignments)

      it "throws RuntimeError exception" do
        expect do
          shifts = generate_shifts(members, count, [asgn1])
        end.to raise_error(RuntimeError, "MAX RETRY COUNT FOR MAIN EXCEEDED.")
      end
    end
  end
end