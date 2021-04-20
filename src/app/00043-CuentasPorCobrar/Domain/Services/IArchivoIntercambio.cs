using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IArchivoIntercambio
    {
        List<ArchivoIntercambio> Find();
        ArchivoIntercambio Find(int estructuraArchivoID);
        Response Save(ArchivoIntercambio archivoIntercambio, int currentUserId, SaveOption saveOption);
        Response ChangeState(int estructuraArchivoID, bool currentState, int currentUserId);


        List<SeccionArchivo> FindSeccionesArchivos(); 
        List<SeccionArchivo> FindSeccionesArchivos(int TipoArchivoEntidadID); 
        List<ColumnaSeccion> FindColumnasSeccion(); 
        List<ColumnaSeccion> FindColumnasSeccion(int SeccionArchivoId);


        Response EstructuraSeccionSave(SeccionArchivo seccionesArchivo, List<ColumnaSeccion> columnasSeccion, int currentUserId, SaveOption saveOption);
        Response SeccionChangeState(int seccionArchivoId, bool currentState, int currentUserId);
        Response ColumnaChangeState(int columnaSeccionId, bool currentState, int currentUserId);

    }
}
