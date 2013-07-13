/*
Copyright (c) 2013 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dlib.mesh.triangle;

private
{
    import std.math;
    import dlib.math.vector;
    import dlib.geometry.aabb;
}

struct Triangle
{
    public:
    Vector3f[3] v;
    Vector3f[3] n;
    Vector2f[3] t1;
    Vector2f[3] t2;
	
    Vector3f[3] edges;
    Vector3f normal;
    Vector3f barycenter;
    float d;
    
    int materialIndex;
    
    int isPointInside(Vector3f point)
    {
        //select coordinate
        int dim0, dim1, plane;
        float clockness; // 1.0 counter clockwise, -1.0 clockwise

        if (abs(normal[1]) > abs(normal[2]))
        {
            if (abs(normal[1]) > abs(normal[0])) //use y plane
            {
                plane = 1;
                dim0 = 2; //0;
                dim1 = 0; //2;
            }
            else //use x plane
            {
                plane = 0;
                dim0 = 1;
                dim1 = 2;
            }
        }
        else if (abs(normal[2]) > abs(normal[0])) //use z plane
        {
            plane = 2;
            dim0 = 0;
            dim1 = 1;
        }
        else //use x plane
        {
            plane = 0;
            dim0 = 1;
            dim1 = 2;
        }

        clockness = (normal[plane] > 0.0f)? 1.0f : -1.0f;

        float det0, det1, det2;

        det0 = (point[dim0] - v[0][dim0]) * (v[0][dim1] - v[1][dim1]) + 
               (v[0][dim1] - point[dim1]) * (v[0][dim0] - v[1][dim0]);
    
        det1 = (point[dim0] - v[1][dim0]) * (v[1][dim1] - v[2][dim1]) + 
               (v[1][dim1] - point[dim1]) * (v[1][dim0] - v[2][dim0]);
    
        det2 = (point[dim0] - v[2][dim0]) * (v[2][dim1] - v[0][dim1]) + 
               (v[2][dim1] - point[dim1]) * (v[2][dim0] - v[0][dim0]);

        int ret;

        if (det0 > 0.0f)
        {
            if (det1 > 0.0f)
            {
                if (det2 > 0.0f)
                    ret = -1; // inside
                else
                    ret = 5; // outside edge 2
            }
            else 
            {
                if (det2 > 0.0f)
                    ret = 3; // outside edge 1
                else
                    ret = 4; // outside vertex 2
            }
        }
        else 
        {
            if (det1 > 0.0f)
            {
                if (det2 > 0.0f)
                    ret = 1; // outside edge 0
                else
                    ret = 0; // outside vertex 0
            }
            else
            {
                if (det2 > 0.0f)
                    ret = 2; // outside vertex 1
                else
                    ret = -1; // inside
            }
        }

        if (ret == -1)
            return ret;

        if (clockness == -1.0f)
            ret = (ret + 3) % 6;

        return ret;
    }

    AABB boundingBox()
    {
        Vector3f pmin = v[0];
        Vector3f pmax = pmin;
    
        void adjustMinPoint(Vector3f p)
        {    
            if (p.x < pmin.x) pmin.x = p.x;
            if (p.y < pmin.y) pmin.y = p.y;
            if (p.z < pmin.z) pmin.z = p.z;
        }
    
        void adjustMaxPoint(Vector3f p)
        {
            if (p.x > pmax.x) pmax.x = p.x;
            if (p.y > pmax.y) pmax.y = p.y;
            if (p.z > pmax.z) pmax.z = p.z;
        }

        foreach(vertex; v)
        {
            adjustMinPoint(vertex);
            adjustMaxPoint(vertex);
        }
    
        return boxFromMinMaxPoints(pmin - 0.5f, pmax + 0.5f);
    }
}
