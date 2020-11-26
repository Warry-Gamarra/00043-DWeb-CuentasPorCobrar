using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Domain.Services
{
    public interface IMigracionTablas
    {
        Response GuardarTabla(string pathFile, HttpPostedFileBase file, TablaMigracion tablaMigracion, int currentUserId);
    }
}
