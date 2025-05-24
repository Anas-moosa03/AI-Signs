import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentTransaction
import com.mycompany.travelapp.mediapipe.CameraFragment
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

//class CameraFragmentFactory(private val activity: FragmentActivity) :
//    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
//
//    override fun create(context: Context, id: Int, args: Any?): PlatformView {
//        return CameraFragmentPlatformView(activity)
//    }
//}
//
//class CameraFragmentPlatformView(private val activity: FragmentActivity) : PlatformView {
//
//    private val fragment = CameraFragment()
//
//    init {
//        activity.supportFragmentManager.beginTransaction()
//            .replace(android.R.id.content, fragment)
//            .commit()
//    }
//
//    override fun getView(): View? {
//        return fragment.view
//    }
//
//    override fun dispose() {
//        activity.supportFragmentManager.beginTransaction().remove(fragment).commit()
//    }
//}


//class CameraFragmentFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
//    override fun create(context: Context, id: Int, args: Any?): PlatformView {
//        val activity = context as? FragmentActivity
//            ?: throw IllegalArgumentException("Context is not a FragmentActivity")
//        val fragment = CameraFragment() // Your custom camera fragment
//        activity.supportFragmentManager
//            .beginTransaction()
//            .replace(id, fragment)
//            .commit()
//        return object : PlatformView {
//            override fun getView(): View {
//                return FrameLayout(context).apply { id = View.generateViewId() }
//            }
//            override fun dispose() {}
//        }
//    }
//}
