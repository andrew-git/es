package alecmce.es.core.impl
{
    public interface System
    {
        function start(time:int):void;

        function update(time:int, delta:int):void;

        function stop(time:int):void;
    }
}
