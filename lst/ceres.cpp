struct Residual
{
    template <typename T>
    bool operator()(const T * const cam, const T * const point, T *residual) const
    {
        T p[3];
        ceres::AngleAxisRotatePoint(cam, point, p); // Rotate.
        p[0] += c.x; p[1] += c.y; p[2] += c.z;      // Translate.
        T xp = -p[0] / p[2], yp = -p[1] / p[2];     // Perspective correction.
        residual[0] = cam[3] * xp - p_im.x;         // Compute residuals.
        residual[1] = cam[3] * yp - p_im.y;
        return true;
    }
    cv::Point3d c;
    cv::Point2d p_im;
};
