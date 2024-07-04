// #include "tf_test/tf_test.hpp"

// C++ system
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include <rclcpp/logging.hpp>
#include <rclcpp/qos.hpp>
#include <rclcpp/utilities.hpp>
#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.hpp>
// #include <serviceinterface.h> // local
// #include <Poco/Net/ServerSocket.h> // system

namespace vr_track_tcp {

class VrTrackTcp: public rclcpp::Node {
private:
public:
    explicit VrTrackTcp(const rclcpp::NodeOptions& options): Node("vr_track_tcp", options) {
        RCLCPP_INFO(this->get_logger(), "hello");
    };

    ~VrTrackTcp() override = default;
};

} // namespace vr_track_tcp

#include "rclcpp_components/register_node_macro.hpp"

// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable
// when its library is being loaded into a running process.
RCLCPP_COMPONENTS_REGISTER_NODE(vr_track_tcp::VrTrackTcp)
