using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Domain.Services
{
    public interface IEstudiante
    {
        Response CargarDataAptos(string pathFile, HttpPostedFileBase file, TipoAlumno tipoAlumno, int currentUserId);
    }
}
