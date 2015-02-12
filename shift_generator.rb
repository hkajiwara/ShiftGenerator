module ShiftGenerator
  MAX_RETRY_COUNT_FOR_MAIN   = 1500
  MAX_RETRY_COUNT_FOR_SELECT = 1000

  def generate_shifts(members, count, assignments)
    retry_counter = 0

    begin
      shifts = Array.new(count){ Array.new(assignments.size) }
      source = Array.new(assignments.size) { Array.new(Marshal.load(Marshal.dump(members))) }

      # iterate over the count of shifts
      count.times do |shift_count|
        # iterate over the count of assignment types
        assignments.each_with_index do |assignment, assignment_index|
          assined_members  = Array.new(assignment.member_assignments.size)

          # iterate over the count of assignment groups
          assignment.member_assignments.size.times do |assignment_group|          
            selected_members = select_members(
                                source[assignment_index], 
                                assignment.member_assignments[assignment_group],
                                shifts[shift_count].flatten + 
                                assined_members.flatten)

            if source[assignment_index].size >= assignment.member_assignments[assignment_group] then
              source[assignment_index] -= selected_members
              assined_members[assignment_group] = selected_members
            else
              additional_members = select_members(
                                    Marshal.load(Marshal.dump(members)) - selected_members,
                                    assignment.member_assignments[assignment_group] - selected_members.size,
                                    shifts[shift_count].flatten + 
                                    assined_members.flatten)
              source[assignment_index] = Marshal.load(Marshal.dump(members)) - additional_members
              assined_members[assignment_group] = selected_members + additional_members
            end
          end
          shifts[shift_count][assignment_index] = assined_members
        end
      end
    rescue
      retry_counter += 1
      if retry_counter <= MAX_RETRY_COUNT_FOR_MAIN
        # puts "***** RETRY FOR MAIN " + retry_counter.to_s + " *****"
        retry
      else
        puts "MAX RETRY COUNT FOR MAIN EXCEEDED."
        raise "MAX RETRY COUNT FOR MAIN EXCEEDED."
      end
    end

    # show_assignments(members, shifts, "==================== SUMMARY ===================") if shifts.size != 0
    return shifts
  end

  class Assignment
    attr_accessor :assignment_name, :member_assignments, :time_assignments
    def initialize(assignment_name, member_assignments, time_assignments)
      @assignment_name    = assignment_name
      @member_assignments = member_assignments
      @time_assignments   = time_assignments
    end
  end

  private
    def select_members(members, count, assigned_members)
      retry_counter = 0
      target = members.sample(count)
      until (assigned_members & target).empty? do
        if retry_counter > MAX_RETRY_COUNT_FOR_SELECT then 
          raise "MAX RETRY COUNT FOR SELECT EXCEEDED" 
        end
        retry_counter += 1
        target = members.sample(count)
      end
      return target
    end

    def show_assignments(members, shifts, message)
      p message

      shifts[0].each_with_index do |assignment, assignment_index|
        p "================= Assignment #{assignment_index+1} ================="
        
        assignment_counts = Hash.new(0)
        shifts.each_with_index do |shift|
          shift[assignment_index].flatten.each do |member|
            assignment_counts[member] += 1
          end
        end
        assignment_counts.sort_by {|k, v| v}.reverse.each do |member|
          p member
        end
        p ""
      end
    end
end